#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

init()
{
    // Precache stock perk machine model and collision box
    precachemodel("zombie_vending_jugg"); 
    precachemodel("collision_geo_64x64x128");

    level thread on_player_connect();
    level thread spawn_ammomatic();
}

on_player_connect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread on_player_spawned();
    }
}

on_player_spawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
    }
}

spawn_ammomatic()
{
    level waittill("initial_blackscreen_passed");

    // Coordinates for the machine
    origin = (-160, -812, 80); 
    angles = (0, 45, 0);

    // Spawn physical machine model
    machine = spawn("script_model", origin);
    machine setmodel("zombie_vending_jugg");
    machine.angles = angles;

    // Spawn invisible collision box so players can't walk through it
    collision = spawn("script_model", origin);
    collision setmodel("collision_geo_64x64x128");
    collision.angles = angles;

    // Spawn interact trigger (Radius: 40, Height: 70)
    trig = spawn("trigger_radius", origin, 0, 40, 70);
    trig sethintstring("Press ^3&&1^7 to buy Amm-O-Matic [Cost: 10000]");
    trig setcursorhint("HINT_NOICON");

    // Listen for player interactions
    for(;;)
    {
        trig waittill("trigger", player);

        cost = 10000;

        if(player.score >= cost && player usebuttonpressed())
        {
            player.score -= cost;
            player playsound("zmb_buy_perk");

            // Give max ammo to all current weapons
            weapons = player getweaponslistprimaries();
            for(i = 0; i < weapons.size; i++)
            {
                player givemaxammo(weapons[i]);
            }

            // Cooldown before next purchase
            wait(3);
        }
        wait(0.1);
    }
}