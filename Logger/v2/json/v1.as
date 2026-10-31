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

/**
 * @file Logger/v2/json/v1.as
 * @brief JSON v1 configuration support for Logger v2.
 *
 * This compatibility module converts JSON v1 data to AngelScript
 * dictionaries before applying logger level states.
 */

#include "../../../meta_api/json/v1"

namespace Logger
{
    namespace json
    {
        /**
         * @brief JSON v1 based logger configuration helpers.
         */
        namespace v1
        {
            /**
             * @brief Builds the schema properties for all registered loggers.
             * @return A dictionary containing logger configuration properties.
             */
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

            /**
             * @brief Builds the complete logger configuration schema.
             * @return A dictionary containing the JSON v1 schema.
             */
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

            /**
             * @brief Applies logger level states from JSON text or a file.
             * @param obj JSON text or a recognized JSON filename.
             */
            void configure( const string&in obj )
            {
                dictionary@ obj2;
                meta_api::json::v1::Deserialize( obj, @obj2 );
                configure( obj2 );
            }

            /**
             * @brief Applies logger level states from a dictionary.
             * @param obj Dictionary containing logger names and level states.
             */
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
