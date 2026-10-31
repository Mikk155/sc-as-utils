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

/**
 * @file Logger/v2.as
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
    funcdef bool PrintCallback( string&in, const Level&in );

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
     *         function( string&in message, const Logger::Level&in level ) {
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
        /**
         * @brief Optional callback invoked after the level callback.
         *
         * Callbacks run in level, logger, and global configuration order.
         */
        PrintCallback@ Callback;

        protected
            /** @brief Internal name used in formatted messages. */
            string m_name;

        /** @brief Gets the name of this object. */
        const string& get_name() const property final
        {
            return this.m_name;
        }

        /** @brief Sets the name of this object. */
        void set_name( const string&in value ) property
        {
            this.m_name = value;
        }

        protected
            /** @brief Internal activation state. */
            bool m_active = true;

        /** @brief Whether this object is active. */
        const bool get_active() const property
        {
            return this.m_active;
        }

        /** @brief Sets the activation state of this object. */
        void set_active( bool value ) property
        {
            this.m_active = value;
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
            weakref<Logger> m_owner;

        /** @brief Gets the logger that owns this level. */
        const Logger@ get_owner() const property
        {
            return this.m_owner.get();
        }

        /** @brief Whether both this level and its owner are active. */
        const bool get_active() const property override
        {
            return ( Base::get_active() && this.owner !is null && this.owner.active );
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
            this.name = levelName;

            this.m_owner.opHndlAssign( ownerLogger );

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
        string format( string&in message, const string[]@ args = null, const dictionary@ kwargs = null ) const
        {
            string buffer;

            const Logger@ owner = this.owner;

            if( Config.PrefixWithGlobalName && !Config.GlobalName.IsEmpty() )
            {
                buffer.opAddAssign( '[' );
                buffer.opAddAssign( Config.GlobalName );
                buffer.opAddAssign( "] " );
            }

            if( !owner.name.IsEmpty() )
            {
                buffer.opAddAssign( '[' );
                buffer.opAddAssign( owner.name );
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
         * @brief Sends an already formatted message when this level is active.
         * @param message Formatted message to send.
         * @return True when all applicable callbacks accept the message.
         */
        bool printf( string&in message ) const
        {
            if( !this.active )
            {
                return false;
            }

            if( this.Callback !is null )
            {
                if( !this.Callback( message, this ) )
                {
                    return false;
                }
            }

            Logger@ ownerLogger;
            if( ( @ownerLogger = this.m_owner.get() ) !is null && ownerLogger.Callback !is null )
            {
                if( !ownerLogger.Callback( message, this ) )
                {
                    return false;
                }
            }

            if( Config.Callback !is null )
            {
                if( !Config.Callback( message, this ) )
                {
                    return false;
                }
            }

            return true;
        }

        /**
         * @brief Formats and sends a message when this level is active.
         * @param message Message template.
         * @param args Values substituted into `{}` placeholders.
         * @param kwargs Values substituted into `{name}` placeholders.
         * @return True when the message was sent; otherwise false.
         */
        bool print( string&in message, const string[]@ args = null, const dictionary@ kwargs = null ) const
        {
            if( !this.active )
            {
                return false;
            }

            return this.printf( this.format( message, args, kwargs ) );
        }

        /**
         * @brief Allows a level to be used as a callable logger.
         * @param message Message template.
         * @param args Values substituted into `{}` placeholders.
         * @param kwargs Values substituted into `{name}` placeholders.
         * @return True when the message was sent; otherwise false.
         */
        bool opCall( string&in message, const string[]@ args = null, const dictionary@ kwargs = null ) const
        {
            return this.print( message, args, kwargs );
        }
    }

    /** @brief All currently registered Logger instances, indexed by name. */
    dictionary g_Loggers;

    /**
     * @brief Deletes every logger from the registry.
     *
     * Loggers held by strong references elsewhere remain alive.
     */
    void Shutdown()
    {
        g_Loggers.deleteAll();
    }

    /**
     * @brief Removes one logger from the registry.
     * @param logger Logger to remove.
     *
     * The logger remains alive while another strong reference owns it.
     */
    void Shutdown( Logger@ logger )
    {
        if( logger.name.IsEmpty() )
        {
            g_Loggers.delete( "global" );
        }
        else
        {
            g_Loggers.delete( logger.name );
        }
    }

    /**
     * @brief Iterates over the loggers currently in the registry.
     */
    final class Iterator
    {
        private
            uint m_Current;

        private
            array<string>@ m_Names;

        /**
         * @brief Gets the next logger.
         * @return The next logger, or null after the final entry.
         */
        Logger@ Next()
        {
            if( this.m_Current >= this.m_Names.length() )
                return null;

            return cast<Logger@>( g_Loggers[ this.m_Names[ this.m_Current++ ] ] );
        };

        /**
         * @brief Gets the next logger through an output parameter.
         * @param logger Receives the next logger.
         * @return True when a logger was returned.
         */
        bool Next( Logger@&out logger )
        {
            @logger = this.Next();
            return ( logger !is null );
        };

        /**
         * @brief Creates an iterator snapshot of the current registry names.
         */
        Iterator()
        {
            @this.m_Names = g_Loggers.getKeys();
            this.m_Current = 0;
        }
    }

    /**
     * @brief Changes the active state of every registered logger.
     * @param state New active state.
     * @param levelsToo Also apply the state to every logger level.
     */
    void SetStateAll( bool state, bool levelsToo = false )
    {
        Iterator it;
        Logger@ logger;
        while( it.Next( logger ) )
        {
            logger.SetActive( state );

            if( levelsToo )
            {
                int idx = 0;
                Level@ level;
                while( ( @level = logger.GetLevel(idx++) ) !is null )
                {
                    level.active = state;
                }
            }
        }
    }

    /**
     * @brief Gets a registered logger by name.
     * @param loggerName Name to search for.
     * @return The matching logger, or null when it does not exist.
     */
    Logger@ First( const string&in loggerName )
    {
        if( loggerName.IsEmpty() )
        {
            return First( "global" );
        }

        Logger@ logger;
        g_Loggers.get( loggerName, @logger );
        return logger;
//        return cast<Logger@>( g_Loggers[ loggerName ] );
    }

    /**
     * @brief Finds a registered logger without creating one.
     * @param loggerName Name to search for.
     * @return A weak reference to the matching logger.
     */
    weakref<Logger> Find( const string&in loggerName )
    {
        weakref<Logger> loggerRef;
        loggerRef.opHndlAssign( First( loggerName ) );
        return loggerRef;
    }

    /**
     * @brief Finds a registered logger and reports whether it exists.
     * @param loggerName Name to search for.
     * @param logger Receives a weak reference to the matching logger.
     * @return True when a matching logger exists.
     */
    bool Find( const string&in loggerName, weakref<Logger>&out logger )
    {
        logger = Find( loggerName );
        return ( logger.get() !is null );
    }

    /**
     * @brief Gets a registered logger, creating it when necessary.
     * @param loggerName Name for the logger; empty selects the global logger.
     * @return A weak reference to the registered logger.
     */
    weakref<Logger> FirstOrDefault( string&in loggerName = String::EMPTY_STRING )
    {
        Logger@ logger;
        string labelName = ( loggerName.IsEmpty() ? "global" : loggerName );

        if( !g_Loggers.get( labelName, @logger ) || logger is null )
        {
            @logger = Logger();
            @g_Loggers[ labelName ] = logger;
        }

        if( !loggerName.IsEmpty() )
        {
            logger.SetName( loggerName );
        }

        weakref<Logger> loggerRef;
        loggerRef.opHndlAssign( logger );

        return loggerRef;
    }

    /**
     * @brief Gets or creates a named shared logger.
     * @param loggerName Name of the shared logger.
     * @return A weak reference to the shared logger.
     */
    weakref<Logger> Shared( string&in loggerName )
    {
        return FirstOrDefault( loggerName );
    }

    /**
     * @brief Gets or creates the global logger.
     * @return A weak reference to the logger named `global`.
     */
    weakref<Logger> Global()
    {
        return FirstOrDefault( String::EMPTY_STRING );
    }

    /**
     * @brief Gets or creates a registered logger.
     * @param name Logger name; empty selects the global logger.
     * @return A weak reference to the registered logger.
     */
    weakref<Logger> Register( const string&in name = String::EMPTY_STRING )
    {
        return FirstOrDefault( name );
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
    /** @brief Weak references to the levels owned by this logger. */
    array<weakref<Logger::Level>> __Levels__;

    /**
     * @brief Creates an active logger with its standard levels.
     *
     * The logger must be active for an active level to print a message.
     */
    Logger()
    {
        this.active = true;
    }

    /**
     * @brief Removes this logger from the global registry.
     */
    void shutdown()
    {
        Logger::Shutdown(this);
    }

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

            if( level !is null && level.name == levelName )
                return level;
        }
        return null;
    }

    /**
     * @brief Gets a level by name.
     * @param levelName Level name, such as `error` or `warning`.
     * @return The matching level, or null when it does not exist.
     */
    Logger::Level@ GetLevel( const string&in levelName )
    {
        const uint length = this.__Levels__.length();

        for( uint ui = 0; ui < length; ui++ )
        {
            Logger::Level@ level = this.__Levels__[ui].get();

            if( level !is null && level.name == levelName )
                return level;
        }
        return null;
    }

    /**
     * @brief Gets a level by numeric index.
     * @param idx Zero-based level index.
     * @return The level at the index, or null when it is out of range.
     */
    const Logger::Level@ GetLevel( uint idx ) const
    {
        if( idx < this.__Levels__.length() )
            return this.__Levels__[idx].get();
        return null;
    }

    /**
     * @brief Gets a level by signed numeric index.
     * @param idx Zero-based level index.
     * @return The level at the index, or null for a negative or invalid index.
     */
    const Logger::Level@ GetLevel( int idx ) const
    {
        if( idx >= 0 )
            return this.GetLevel( uint(idx) );
        return null;
    }

    /**
     * @brief Gets a mutable level by numeric index.
     * @param idx Zero-based level index.
     * @return The level at the index, or null when it is out of range.
     */
    Logger::Level@ GetLevel( uint idx )
    {
        if( idx < this.__Levels__.length() )
            return this.__Levels__[idx].get();
        return null;
    }

    /**
     * @brief Gets a mutable level by signed numeric index.
     * @param idx Zero-based level index.
     * @return The level at the index, or null for a negative or invalid index.
     */
    Logger::Level@ GetLevel( int idx )
    {
        if( idx >= 0 )
            return this.GetLevel( uint(idx) );
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
        this.name = name;
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
    /** @brief Gets the trace level. @return The trace level. */
    const Logger::Level& get_trace() const property {
        return this.m_trace;
    }

    /** @brief Debug level, disabled by default. */
    protected Logger::Level m_debug( "debug", this, false );
    /** @brief Gets the debug level. @return The debug level. */
    const Logger::Level& get_debug() const property {
        return this.m_debug;
    }

    /** @brief Info level, disabled by default. */
    protected Logger::Level m_info( "info", this, false );
    /** @brief Gets the info level. @return The info level. */
    const Logger::Level& get_info() const property {
        return this.m_info;
    }

    /** @brief Warning level, enabled by default. */
    protected Logger::Level m_warning( "warning", this, true );
    /** @brief Gets the warning level. @return The warning level. */
    const Logger::Level& get_warning() const property {
        return this.m_warning;
    }

    /** @brief Error level, enabled by default. */
    protected Logger::Level m_error( "error", this, true );
    /** @brief Gets the error level. @return The error level. */
    const Logger::Level& get_error() const property {
        return this.m_error;
    }

    /** @brief Critical level, enabled by default. */
    protected Logger::Level m_critical( "critical", this, true );
    /** @brief Gets the critical level. @return The critical level. */
    const Logger::Level& get_critical() const property {
        return this.m_critical;
    }
}
