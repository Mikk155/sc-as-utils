#if FALSE
/**
 * @file Logger/v1.as
 * @brief Configurable logging utilities.
 *
 * A logger is composed of a name and a set of log levels. Messages are
 * formatted with the logger name, level name, and optional global name before
 * they are sent to the callback configured in @ref Logger::Config.
 *
 * @warning The callback in @ref Logger::Config must be configured before any
 * logger attempts to print a message.
 */
namespace Logger
{
    /**
     * @brief Receives a formatted log message and the level that produced it.
     *
     * The callback is invoked by Logger::Level::print after the message has
     * been formatted. The message includes a trailing newline by default.
     */
    funcdef void PrintCallback( const string&in, const Level&in );

    /**
     * @brief Global options used by every logger and level.
     *
     * Configuration uses a fluent interface, so setters can be chained.
     *
     * @par Registering a callback
     * Configure the callback and, optionally, the global name during startup:
     * @code
     * Logger::Config
     *     .SetCallback(
     *         function( const string&in message, const Logger::Level&in level ) {
     *             g_Game.AlertMessage( at_console, message );
     *         }
     *     )
     *     .SetGlobalName( g_Module.GetModuleName() );
     * @endcode
     */
    final class Configuration
    {
        /** @brief Destination invoked for every message that is printed. */
        PrintCallback@ Callback;

        /**
         * @brief Sets the destination callback for formatted messages.
         * @param callback Function that receives the message and its level.
         * @return This configuration object.
         */
        Configuration@ SetCallback( PrintCallback@ callback ) {
            @this.Callback = callback;
            return this;
        }

        /**
         * @brief Whether unmatched positional arguments are treated as errors.
         *
         * When true, a positional argument without a corresponding `{}` token
         * reports an error and aborts formatting.
         */
        bool SensitiveArguments = true;

        /**
         * @brief Enables or disables validation of positional arguments.
         * @param sensitiveArguments Whether unmatched arguments are errors.
         * @return This configuration object.
         */
        Configuration@ SetSensitiveArguments( bool sensitiveArguments ) {
            this.SensitiveArguments = sensitiveArguments;
            return this;
        }

        /**
         * @brief Whether unmatched or empty keyword arguments are errors.
         */
        bool SensitiveKeywordArguments = true;

        /**
         * @brief Enables or disables validation of keyword arguments.
         * @param sensitiveKeywordArguments Whether invalid keyword arguments
         * are errors.
         * @return This configuration object.
         */
        Configuration@ SetSensitiveKeywordArguments( bool sensitiveKeywordArguments ) {
            this.SensitiveKeywordArguments = sensitiveKeywordArguments;
            return this;
        }

        /** @brief Whether formatted messages receive a trailing newline. */
        bool AppendNewline = true;

        /**
         * @brief Enables or disables the trailing newline in formatted output.
         * @param appendNewline Whether to append a newline when absent.
         * @return This configuration object.
         */
        Configuration@ SetAppendNewline( bool appendNewline ) {
            this.AppendNewline = appendNewline;
            return this;
        }

        /** @brief Whether the global name is included in each message prefix. */
        bool PrefixWithGlobalName = true;

        /**
         * @brief Enables or disables the global-name message prefix.
         * @param prefixWithGlobalName Whether to include @ref GlobalName.
         * @return This configuration object.
         */
        Configuration@ SetPrefixWithGlobalName( bool prefixWithGlobalName ) {
            this.PrefixWithGlobalName = prefixWithGlobalName;
            return this;
        }

        /** @brief Optional name shown before the logger name in each prefix. */
        string GlobalName;

        /**
         * @brief Sets the global name used in message prefixes.
         * @param globalName Name to display before the logger name.
         * @return This configuration object.
         */
        Configuration@ SetGlobalName( const string&in globalName ) {
            this.GlobalName = globalName;
            return this;
        }
    }

    /** @brief Shared configuration used by all Logger instances. */
    Configuration@ Config = Configuration();

    /** @brief Common name and activation state shared by loggers and levels. */
    abstract class Base
    {
        protected
            /** @brief Internal name used in formatted messages. */
            string m_Name;

        /** @brief Gets the name of this object. */
        const string& get_Name() const property final
        {
            return this.m_Name;
        }

        /** @brief Sets the name of this object. */
        void set_Name( const string&in value ) property
        {
            this.m_Name = value;
        }

        protected
            /** @brief Internal activation state. */
            bool m_Active;

        /** @brief Whether this object is active. */
        const bool get_active() const property
        {
            return this.m_Active;
        }

        /** @brief Sets the activation state of this object. */
        void set_active( bool value ) property
        {
            this.m_Active = value;
        }
    }

    /**
     * @brief A named level belonging to a Logger.
     *
     * Levels can be called like functions. Positional placeholders use `{}`,
     * while keyword placeholders use `{name}`.
     */
    class Level : Base
    {
        protected
            /** @brief Display name used for the formatted message label. */
            string m_MessageName;

        protected
            /** @brief Logger that owns this level. */
            weakref<Logger> m_Owner;

        /** @brief Gets the logger that owns this level. */
        const Logger@ get_Owner() const property
        {
            return this.m_Owner.get();
        }

        /** @brief Whether both this level and its owner are active. */
        const bool get_active() const property override
        {
            return ( Base::get_active() && this.Owner !is null && this.Owner.active );
        }

        /**
         * @brief Creates a level and attaches it to its owner.
         * @param levelName Internal name of the level.
         * @param ownerLogger Logger to which this level belongs.
         * @param startActive Initial activation state.
         * @param messageName Optional label used in formatted output.
         */
        Level( const string&in levelName, Logger@ ownerLogger, bool startActive = false, const string&in messageName = String::EMPTY_STRING )
        {
            this.active = startActive;
            this.Name = levelName;

            this.m_Owner.opHndlAssign( ownerLogger );

            weakref<Level> thisReference(this);
            ownerLogger.__Levels__.insertLast( thisReference );

            if( messageName.IsEmpty() )
            {
                this.m_MessageName = levelName.SubString( 0, 1 ).ToUppercase() + levelName.SubString( 1 );
            }
            else
            {
                this.m_MessageName = messageName;
            }
        }

        /**
         * @brief Formats a message and its optional arguments.
         * @param message Message template.
         * @param args Values substituted into `{}` placeholders.
         * @param kwargs Values substituted into `{name}` placeholders.
         * @return The formatted message, or false when strict validation fails.
         */
        string format( const string&in message, const string[]@ args = null, const dictionary@ kwargs = null ) const
        {
            string buffer;

            const Logger@ owner = this.Owner;

            if( Config.PrefixWithGlobalName && !Config.GlobalName.IsEmpty() )
            {
                buffer.opAddAssign( '[' );
                buffer.opAddAssign( Config.GlobalName );
                buffer.opAddAssign( "] " );
            }

            if( !owner.Name.IsEmpty() )
            {
                buffer.opAddAssign( '[' );
                buffer.opAddAssign( owner.Name );
                buffer.opAddAssign( "] " );
            }

            buffer.opAddAssign( '[' );
            buffer.opAddAssign( this.m_MessageName );
            buffer.opAddAssign( "] " );
            buffer.opAddAssign( message );

            if( args !is null )
            {
                const uint length = args.length();

                for( uint ui = 0; ui < length; ui++ )
                {
                    uint index = buffer.Find( "{}" );

                    if( index == String::INVALID_INDEX )
                    {
                        if( Config.SensitiveArguments )
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
                        if( Config.SensitiveKeywordArguments )
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
                        if( Config.SensitiveKeywordArguments )
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

            if( Config.AppendNewline && !buffer.EndsWith( '\n' ) )
            {
                buffer.opAddAssign( '\n' );
            }

            return buffer;
        }

        /**
         * @brief Formats and sends a message when this level is active.
         * @param message Message template.
         * @param args Values substituted into `{}` placeholders.
         * @param kwargs Values substituted into `{name}` placeholders.
         * @return True when the message was sent; otherwise false.
         */
        bool print( const string&in message, const string[]@ args = null, const dictionary@ kwargs = null ) const
        {
            if( !this.active )
            {
                return false;
            }

            Config.Callback( format( message, args, kwargs ), this );

            return true;
        }

        /**
         * @brief Allows a level to be used as a callable logger.
         * @param message Message template.
         * @param args Values substituted into `{}` placeholders.
         * @param kwargs Values substituted into `{name}` placeholders.
         * @return True when the message was sent; otherwise false.
         */
        bool opCall( const string&in message, const string[]@ args = null, const dictionary@ kwargs = null ) const
        {
            return this.print( message, args, kwargs );
        }
    }

    /** @brief Weak references to all currently registered Logger instances. */
    array<weakref<Logger>> g_LoggerRefs;

    /**
     * @brief Finds a logger by name and returns a weak reference.
     * @param loggerName Name to search for.
     * @param logger Receives the matching weak reference.
     * @return True when a matching live logger is found.
     */
    bool Find( const string&in loggerName, weakref<Logger>&out logger )
    {
        const uint length = g_LoggerRefs.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            logger = g_LoggerRefs[ui];

            if( logger.get() !is null && loggerName == logger.get().Name )
                return true;
        }
        logger.opHndlAssign(null);
        return false;
    }

    /**
     * @brief Finds a logger by name and returns a handle.
     * @param loggerName Name to search for.
     * @param logger Receives the matching logger handle.
     * @return True when a matching live logger is found.
     */
    bool Find( const string&in loggerName, Logger@&out logger )
    {
        const uint length = g_LoggerRefs.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            @logger = g_LoggerRefs[ui].get();

            if( logger !is null && loggerName == logger.Name )
                return true;
        }
        @logger = null;
        return false;
    }

    /**
     * @brief Finds a logger by name.
     * @param loggerName Name to search for.
     * @return The matching logger, or null when it does not exist.
     */
    const Logger@ Find( const string&in loggerName )
    {
        Logger@ logger;
        Find( loggerName, logger );
        return logger;
    }

    /**
     * @brief Alias for Find(const string&in).
     * @param loggerName Name to search for.
     * @return The matching logger, or null when it does not exist.
     */
    const Logger@ First( const string&in loggerName )
    {
        return Find( loggerName );
    }

    /**
     * @brief Finds a logger or creates a named default logger.
     * @param loggerName Name to search for or assign to the new logger.
     * @return The existing logger or a newly created logger.
     */
    const Logger@ FirstOrDefault( const string&in loggerName )
    {
        const Logger@ logger = Find( loggerName );

        if( logger is null )
        {
            return Logger().SetName( loggerName );
        }

        return logger;
    }
}

/**
 * @brief Named logger with trace, debug, info, warning, error, and critical levels.
 *
 * A new logger is registered automatically while it exists. A logger is active
 * by default; individual levels have their own default activation states.
 */
class Logger : Logger::Base
{
    /**
     * @brief Creates and registers a logger.
     * @param name Optional name included in formatted messages.
     * @param startActive Initial activation state for the logger.
     */
    Logger( const string&in name = String::EMPTY_STRING, bool startActive = true )
    {
        this.Name = name;
        this.active = startActive;
        weakref<Logger::Logger> loggerReference(this);
        Logger::g_LoggerRefs.insertLast( loggerReference );
    }

    /** @brief Unregisters this logger and removes stale references. */
    ~Logger()
    {
        const uint length = Logger::g_LoggerRefs.length();

        for( uint ui = length -1; ui >= 0; ui-- )
        {
            Logger@ logger = Logger::g_LoggerRefs[ui].get();

            if( logger is null || logger is this )
            {
                Logger::g_LoggerRefs.removeAt(ui);
            }
        }
    }

    /**
     * @brief Gets a weak reference to this logger.
     * @return A weak reference resolved by the logger name.
     */
    weakref<Logger> get_WeakReference() const property
    {
        weakref<Logger> loggerRef;
        Logger::Find( this.Name, loggerRef );
        return loggerRef;
    }

    /** @brief Weak references to the levels owned by this logger. */
    array<weakref<Logger::Level>> __Levels__;

    /**
     * @brief Gets a level by name.
     * @param levelName Level name, such as `error` or `warning`.
     * @return The matching level, or null when it does not exist.
     */
    const Logger::Level@ GetLevel( const string&in levelName ) const
    {
        const uint length = this.__Levels__.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            Logger::Level@ level = this.__Levels__[ui].get();

            if( level !is null && level.Name == levelName )
                return level;
        }
        return null;
    }

    /**
     * @brief Gets a level using index-style syntax.
     * @param levelName Level name to search for.
     * @return The matching level, or null when it does not exist.
     */
    const Logger::Level@ opIndex( const string&in levelName ) const
    {
        return this.GetLevel( levelName );
    }

    /**
     * @brief Changes the logger name.
     * @param name New name for the logger.
     * @return This logger.
     */
    Logger@ SetName( const string&in name )
    {
        this.Name = name;
        return this;
    }

    /**
     * @brief Changes whether this logger is active.
     * @param startActive New activation state.
     * @return This logger.
     */
    Logger@ SetActive( const bool startActive )
    {
        this.active = startActive;
        return this;
    }

    /** @brief Trace level, disabled by default. */
    protected Logger::Level m_trace( "trace", this, false );
    /** @brief Gets the trace level. */
    const Logger::Level& get_trace() const property {
        return this.m_trace;
    }

    /** @brief Debug level, disabled by default. */
    protected Logger::Level m_debug( "debug", this, false );
    /** @brief Gets the debug level. */
    const Logger::Level& get_debug() const property {
        return this.m_debug;
    }

    /** @brief Info level, disabled by default. */
    protected Logger::Level m_info( "info", this, false );
    /** @brief Gets the info level. */
    const Logger::Level& get_info() const property {
        return this.m_info;
    }

    /** @brief Warning level, enabled by default. */
    protected Logger::Level m_warning( "warning", this, true );
    /** @brief Gets the warning level. */
    const Logger::Level& get_warning() const property {
        return this.m_warning;
    }

    /** @brief Error level, enabled by default. */
    protected Logger::Level m_error( "error", this, true );
    /** @brief Gets the error level. */
    const Logger::Level& get_error() const property {
        return this.m_error;
    }

    /** @brief Critical level, enabled by default. */
    protected Logger::Level m_critical( "critical", this, true );
    /** @brief Gets the critical level. */
    const Logger::Level& get_critical() const property {
        return this.m_critical;
    }
}
#endif
