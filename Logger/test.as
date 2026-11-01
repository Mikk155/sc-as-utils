/**
*   MIT License
*
*   Copyright (c) 2026 Mikk155
*
*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
**/

#include "v2"
#include "v2/time"
#include "v2/json/v2"

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
            function( string&in message, const Logger::Level&in level ) {
                Logger::time::format( message, message );
                g_Game.AlertMessage( at_console, message );
                return true;
            }
        )
        .SetGlobalName( g_Module.GetModuleName() );

    weakref<Logger> logger_Ref = Logger::Global();
    Logger@ logger = logger_Ref.get();
//    Logger::SetStateAll( true, true );

    Logger::json::v2::configure( """{
"global": {
    "info": true
}
}""" );

    if( logger !is null )
    {
        logger.info( "single message" );
        logger.info( "message with *args: {} {}!", { "Hello", "world" } );
        logger.info( "message with *kwargs: {h} {w}!", null, { { "h", "Hello" }, { "w", "world" } } );
        logger.info( "message with *args & *kwargs: {} {w}{}", { "Hello", "!" }, { { "w", "world" } } );
    }
}
