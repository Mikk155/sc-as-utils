#include "v2"

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk155" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );
    g_Scheduler.SetTimeout( "StupidSpam", 0.01f );
}

void StupidSpam()
{
    // Configure
    Logger::Config
        .SetCallback(
            function( const string&in message, const Logger::Level&in level ) {
                g_Game.AlertMessage( at_console, message );
            }
        )
        .SetGlobalName( g_Module.GetModuleName() );

    weakref<Logger> logger_Ref = Logger::Global();
    Logger@ logger = logger_Ref.get();

    if( logger !is null )
    {
        logger.error( "single message" );
        logger.error( "message with *args: {} {}!", { "Hello", "world" } );
        logger.error( "message with *kwargs: {h} {w}!", null, { { "h", "Hello" }, { "w", "world" } } );
        logger.error( "message with *args & *kwargs: {} {w}{}", { "Hello", "!" }, { { "w", "world" } } );
    }
}
