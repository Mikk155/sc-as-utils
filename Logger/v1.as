// disable E121
// disable E230
namespace Logger
{
    funcdef void PrintCallback( const string&in, const Level&in );

    // Global name used for commands and the global logger
    string g_GlobalName;
    PrintCallback@ g_PrintCallback;
    bool g_SensitiveArguments = true;
    bool g_SensitiveKeywordArguments = true;
    bool g_AppendNewline = true;

    abstract class Base
    {
        protected
            string m_Name;

        const string& get_Name() const property final
        {
            return this.m_Name;
        }

        void set_Name( const string&in value ) property
        {
            this.m_Name = value;
        }

        protected
            bool m_Active;

        const bool get_Active() const property
        {
            return this.m_Active;
        }

        void set_Active( bool value ) property
        {
            this.m_Active = value;
        }
    }

    abstract class Logger : Base
    {
        array<weakref<Level>> m_Levels;
    }

    class Level : Base
    {
        protected
            weakref<Logger> m_Owner;

        const Logger@ get_Owner() const property
        {
            return this.m_Owner.get();
        }

        const bool get_Active() const property override
        {
            return ( Base::get_Active() && this.Owner !is null && this.Owner.Active );
        }

        Level( const string&in levelName, Logger@ ownerLogger, bool startActive = false )
        {
            this.Active = startActive;
            this.Name = levelName;
            this.m_Owner.opHndlAssign( ownerLogger );
            weakref<Level> thisReference(this);
            ownerLogger.m_Levels.insertLast( thisReference );
        }

        string format( const string&in message, const string[]@ args = null, const dictionary@ kwargs = null ) const
        {
            string buffer = message;

            if( args !is null )
            {
                const uint length = args.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    uint index = buffer.Find( "{}" );

                    if( index == String::INVALID_INDEX )
                    {
                        if( g_SensitiveArguments )
                        {
                            this.opCall( "ERROR got {} arguments but only {} were defined in message: {}", { length, ui, message } );
                            int[]a(0);a[1];
                            return false;
                        }
                        break;
                    }
                    string before = buffer.SubString( 0, index );
                    string after = buffer.SubString( index + 2, buffer.Length() - index - 2 );
                    buffer = before + args[ui] + after;
                }
            }

            if( kwargs !is null )
            {
                const array<string>@ keywords = kwargs.getKeys();
                const uint length = keywords.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    string keyword = keywords[ui];

                    uint index = buffer.Find( '{' + keyword + '}' );

                    if( index == String::INVALID_INDEX )
                    {
                        if( g_SensitiveKeywordArguments )
                        {
                            this.opCall( "ERROR got {} key word but is not defined in message: {}", { keyword, message } );
                            int[]a(0);a[1];
                            return false;
                        }
                        continue;
                    }

                    string replacement = string( kwargs[ keyword ] );

                    if( replacement.IsEmpty() )
                    {
                        if( g_SensitiveKeywordArguments )
                        {
                            this.opCall( "ERROR got empty/non-string key word value in message: {}", { keyword, message } );
                            int[]a(0);a[1];
                            return false;
                        }
                    }

                    const uint size = keyword.Length() + 2;
                    string before = buffer.SubString( 0, index );
                    string after = buffer.SubString( index + size, buffer.Length() - index - size );
                    buffer = before + replacement + after;
                }
            }

            if( g_AppendNewline && !buffer.EndsWith( '\n' ) )
            {
                buffer.opAddAssign( '\n' );
            }

            return buffer;
        }

        bool print( const string&in message, const string[]@ args = null, const dictionary@ kwargs = null ) const
        {
            if( g_PrintCallback is null || !this.Active )
            {
                return false;
            }

            g_PrintCallback( format( message, args, kwargs ), this );

            return true;
        }

        bool opCall( const string&in message, const string[]@ args = null, const dictionary@ kwargs = null ) const
        {
            return this.print( message, args, kwargs );
        }
    }

    array<weakref<Logger>> g_LoggerRefs;
}

class Logger : Logger::Logger
{
    Logger( const string&in loggerName, bool startActive = true )
    {
        this.Name = loggerName;
        this.Active = startActive;

        weakref<Logger::Logger> loggerReference(this);
        Logger::g_LoggerRefs.insertLast( loggerReference );
    }

    private Logger::Level m_trace( "trace", this, false );
    const Logger::Level& get_trace() const property {
        return this.m_trace;
    }

    private Logger::Level m_debug( "debug", this, false );
    const Logger::Level& get_debug() const property {
        return this.m_debug;
    }

    private Logger::Level m_info( "info", this, false );
    const Logger::Level& get_info() const property {
        return this.m_info;
    }

    private Logger::Level m_warning( "warning", this, true );
    const Logger::Level& get_warning() const property {
        return this.m_warning;
    }

    private Logger::Level m_error( "error", this, true );
    const Logger::Level& get_error() const property {
        return this.m_error;
    }

    private Logger::Level m_critical( "critical", this, true );
    const Logger::Level& get_critical() const property {
        return this.m_critical;
    }
}

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor( "Mikk155" );
    g_Module.ScriptInfo.SetContactInfo( "https://github.com/Mikk155/Sven-Co-op" );
    g_Scheduler.SetTimeout( "StupidSpam", 0.01f );
}

void StupidSpam()
{
    // Configure
    Logger::g_GlobalName = g_Module.GetModuleName();
    @Logger::g_PrintCallback = function( const string&in message, const Logger::Level&in level ) {
        g_Game.AlertMessage( at_console, message );
    };

    Logger logger( "Global" );

    logger.error( "single message" );
    logger.error( "message with *args: {} {}!", { "Hello", "world" } );
    logger.error( "message with *kwargs: {h} {w}!", null, { { "h", "Hello" }, { "w", "world" } } );
    logger.error( "message with *args & *kwargs: {} {w}{}", { "Hello", "!" }, { { "w", "world" } } );
}
