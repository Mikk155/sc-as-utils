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
 * @file Logger/v2/time.as
 * @brief Timestamp formatting helpers for Logger v2.
 */

namespace Logger
{
    /**
     * @brief Timestamp formatting helpers.
     */
    namespace time
    {
        /** @brief Date and time format used for log message prefixes. */
        string date_format = "%d/%m/%Y %H:%M:%S";

        /**
         * @brief Prefixes a message with the current local date and time.
         * @param strIn Message to format.
         * @param strOut Receives the formatted message.
         *
         * If the date cannot be formatted, the original message is returned
         * without a timestamp prefix.
         */
        void format( const string&in strIn, string&out strOut )
        {
            strOut = "";

            string strFormated;
            if( DateTime().Format( strFormated, date_format ) > 0 )
            {
                strOut = "[" + strFormated + "] ";
            }

            strOut.opAddAssign( strIn );
        }

        /**
         * @brief Prefixes a message with the current local date and time.
         * @param strIn Message to format.
         * @return The formatted message.
         */
        string format( const string&in strIn )
        {
            string strOut;
            format( strIn, strOut );
            return strOut;
        }
    }
}
