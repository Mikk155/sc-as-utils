/**
*   MIT License
*
*   Copyright (c) 2025 Mikk155
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

#include "../../../meta_api/json/v1"

namespace Logger
{
    namespace json
    {
        namespace v1
        {
            dictionary@ __get_properties__()
            {
                dictionary@ properties = {};

                Logger::Iterator it;
                Logger@ logger;

                while( it.Next( logger ) )
                {
                    dictionary@ levels = {};

                    int idx = 0;
                    Logger::Level@ level;

                    while( ( @level = logger.GetLevel(idx++) ) !is null )
                    {
                        dictionary@ curData = {
                            { "type", "boolean" },
                            { "description", "State for logger level \"" + level.name + "\"" },
                            { "default", level.active }
                        };

                        @levels[ level.name ] = curData;
                    }

                    dictionary property = {
                        { "type", "object" },
                        { "unevaluatedProperties", false },
                        { "title", "Logging settings" },
                        { "description", "Default state for different log levels." },
                        { "properties", levels }
                    };
                    @properties[ logger.name.IsEmpty() ? "global" : logger.name ] = property;
                }

                return properties;
            }

            dictionary@ schema()
            {
                return {
                    { "type", "object" },
                    { "unevaluatedProperties", false },
                    { "title", "Logging settings" },
                    { "description", "Default state for different log levels." },
                    { "properties", __get_properties__() }
                };
            }

            void configure( const string&in obj )
            {
                dictionary@ obj2;
                meta_api::json::v1::Deserialize( obj, @obj2 );
                configure( obj2 );
            }

            void configure( dictionary@ obj )
            {
                if( obj is null )
                    return;

                Logger::Iterator it;
                Logger@ logger;

                while( it.Next( logger ) )
                {
                    string objName = ( logger.name.IsEmpty() ? "global" : logger.name );

                    dictionary@ loggerObject;

                    if( !obj.get( objName, @loggerObject ) || loggerObject is null )
                        continue;

                    const array<string>@ levelNames = loggerObject.getKeys();
                    const uint length = levelNames.length();

                    for( uint ui = 0; ui < length; ui++ )
                    {
                        string levelName = levelNames[ui];
                        bool state = bool( loggerObject[ levelName ] );
                        Logger::Level@ level = logger.GetLevel( levelName );

                        if( level !is null )
                        {
                            level.active = state;
                        }
                    }
                }
            }
        }
    }
}
