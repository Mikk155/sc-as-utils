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
 * @file Logger/v2/json/v2.as
 * @brief JSON v2 configuration support for Logger v2.
 *
 * This module uses the ordered JSON v2 value type instead of AngelScript
 * dictionaries. The configuration schema and configuration data therefore
 * preserve the JSON object model.
 */

#include "../../../meta_api/json/v2"

namespace Logger
{
    namespace json
    {
        /**
         * @brief JSON v2 based logger configuration helpers.
         */
        namespace v2
        {
            /**
             * @brief Builds the schema properties for all registered loggers.
             * @return A JSON object containing logger configuration properties.
             */
            meta_api::json::v2::json@ __get_properties__()
            {
                meta_api::json::v2::json@ properties = meta_api::json::v2::json();

                Logger::Iterator it;
                Logger@ logger;

                while( it.Next( logger ) )
                {
                    meta_api::json::v2::json@ levels = meta_api::json::v2::json();

                    int idx = 0;
                    Logger::Level@ level;

                    while( ( @level = logger.GetLevel(idx++) ) !is null )
                    {
                        meta_api::json::v2::json@ curData = meta_api::json::v2::json();

                        curData.Set( "type", "boolean" );
                        curData.Set( "description", "State for logger level \"" + level.name + "\"" );
                        curData.Set( "default", level.active );

                        levels.Set( level.name, curData );
                    }

                    meta_api::json::v2::json@ property = meta_api::json::v2::json();

                    property.Set( "type", "object" );
                    property.Set( "unevaluatedProperties", false );
                    property.Set( "title", "Logging settings" );
                    property.Set( "description", "Default state for different log levels." );
                    property.Set( "properties", levels );

                    properties.Set( logger.name.IsEmpty() ? "global" : logger.name, property );
                }

                return properties;
            }

            /**
             * @brief Builds the complete logger configuration schema.
             * @return A JSON v2 schema object.
             */
            meta_api::json::v2::json@ schema()
            {
                meta_api::json::v2::json@ result = meta_api::json::v2::json();

                result.Set( "type", "object" );
                result.Set( "unevaluatedProperties", false );
                result.Set( "title", "Logging settings" );
                result.Set( "description", "Default state for different log levels." );
                result.Set( "properties", __get_properties__() );

                return result;
            }

            /**
             * @brief Applies logger level states from JSON text or a file.
             * @param obj JSON text or a recognized JSON filename.
             */
            void configure( const string&in obj )
            {
                meta_api::json::v2::json@ obj2 = meta_api::json::v2::json();

                if( !meta_api::json::v2::Deserialize( obj, @obj2 ) )
                    return;

                configure( obj2 );
            }

            /**
             * @brief Applies logger level states from a JSON object.
             * @param obj JSON object containing logger names and level states.
             */
            void configure( meta_api::json::v2::json@ obj )
            {
                if( obj is null || !obj.is_object() )
                    return;

                Logger::Iterator it;
                Logger@ logger;

                while( it.Next( logger ) )
                {
                    string objName = ( logger.name.IsEmpty() ? "global" : logger.name );

                    meta_api::json::v2::json@ loggerObject;

                    if( !obj.Get( objName, @loggerObject ) || loggerObject is null || !loggerObject.is_object() )
                        continue;

                    const array<string>@ levelNames = loggerObject.Keys;
                    const uint length = levelNames.length();

                    for( uint ui = 0; ui < length; ui++ )
                    {
                        string levelName = levelNames[ui];
                        bool state;

                        if( !loggerObject.Get( levelName, state, true ) )
                            continue;

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
