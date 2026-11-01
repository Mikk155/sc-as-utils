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
 * @file Logger/v2/file.as
 * @brief Buffered file output helpers for Logger v2.
 */

namespace Logger
{
    /**
     * @brief Buffered file output helpers.
     */
    namespace file
    {
        /** @brief Number of seconds between buffered writes. */
        float g_WriteInterval = 5.0f;

        /** @brief Maximum number of messages written per file and interval. */
        uint g_WriteMaxLogs = 20;

        /** @brief Scheduled callback used to flush buffered messages. */
        CScheduledFunction@ g_ScheduledFunction = null;

        /** @brief Buffered messages grouped by resolved file path. */
        dictionary g_Files;

        /**
         * @brief Resolves a logger filename to the module's store directory.
         * @param filename Relative filename inside the store directory.
         * @return The resolved script file path.
         */
        string getFilePath( const string&in filename )
        {
            return "scripts/" + ( g_Module.GetModuleName() != "MapModule" ? "plugins" : "maps" ) + "/store/" + filename;
        }

        /**
         * @brief Deletes a logger file and clears its pending messages.
         * @param filename Relative filename inside the store directory.
         */
        void delete( const string&in filename )
        {
            string filePath = getFilePath( filename );

            File@ file = g_FileSystem.OpenFile( filePath, OpenFile::OpenFile::WRITE );

            if( file !is null && file.IsOpen() )
            {
                file.Remove();
            }

            g_Files.delete( filePath );
        }

        /**
         * @brief Queues a message for buffered writing.
         * @param message Message to append to the file.
         * @param filename Relative filename inside the store directory.
         */
        void write( string&in message, const string&in filename )
        {
            string filePath = getFilePath( filename );

            array<string>@ logs;

            if( !g_Files.get( filePath, @logs ) || logs is null )
            {
                @logs = { message };
                @g_Files[ filePath ] = logs;
            }
            else
            {
                logs.insertLast( message );
            }

            if( g_ScheduledFunction is null )
            {
                @g_ScheduledFunction = g_Scheduler.SetInterval( "__Logger_file_write__", g_WriteInterval, g_Scheduler.REPEAT_INFINITE_TIMES );
            }
        }
    }
}

/**
 * @brief Flushes buffered Logger v2 messages to their files.
 *
 * This callback is registered automatically by Logger::file::write and removes
 * itself from the scheduler after all pending messages have been written.
 */
void __Logger_file_write__()
{
    dictionary@ files = Logger::file::g_Files;
    array<string>@ filenames = files.getKeys();
    const uint length = filenames.length();

    for( uint ui = 0; ui < length; ui++ )
    {
        string filename = filenames[ui];
        array<string>@ logs;

        if( !files.get( filename, @logs ) || logs is null || logs.length() <= 0)
        {
            files.delete( filename );
            continue;
        }

        File@ file = g_FileSystem.OpenFile( filename, OpenFile::OpenFile::APPEND );

        // if it's null then it may not exist.
        if( file is null )
        {
            @file = g_FileSystem.OpenFile( filename, OpenFile::OpenFile::WRITE );

            if( file !is null && file.IsOpen() )
            {
                file.Write( String::EMPTY_STRING );
                file.Close();
                @file = g_FileSystem.OpenFile( filename, OpenFile::OpenFile::APPEND );
            }
        }

        if( file !is null && file.IsOpen() )
        {
            for( uint ui2 = 0; ui2 < logs.length() && ui2 < Logger::file::g_WriteMaxLogs; ui2++ )
            {
                file.Write( logs[0] );
                logs.removeAt(0);
            }

            file.Close();
        }
    }

    if( files.getSize() <= 0 )
    {
        g_Scheduler.RemoveTimer( Logger::file::g_ScheduledFunction );
        @Logger::file::g_ScheduledFunction = null;
    }
}
