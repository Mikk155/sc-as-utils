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

namespace Player
{
    /**
    *   @brief Utility methods related to player's colormap variable.
    **/
    namespace Colormap
    {
        /**
        *   @brief Gets the player's bottom colormap component normalized to the range [0, 1].
        *   @param player Player whose bottom colormap component is read.
        **/
        float Bottom( CBasePlayer@ player )
        {
            return float( float( uint8( ( player.pev.colormap & 0xFF00 ) >> 8 ) ) / 255.0f );
        }

        /**
        *   @brief Gets the player's top colormap component normalized to the range [0, 1].
        *   @param player Player whose top colormap component is read. If null.
        **/
        float Top( CBasePlayer@ player )
        {
            return float( float( uint8( player.pev.colormap & 0x00FF ) ) / 255.0f );
        }
    }
}
