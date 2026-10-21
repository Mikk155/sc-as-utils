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

namespace Server
{
    class chrono
    {
        private float m_enginetime;
        private uint64 m_ms;
        private TimeDifference m_Difference;
        private DateTime m_Time;

        /**
        *   @brief Get the time of creation of this chronometer.
        **/
        const DateTime& Time
        {
            get const
            {
                return this.m_Time;
            }
        }

        /**
        *   @brief Stop the chrono and build the time difference
        **/
        void Stop()
        {
            DateTime now = DateTime();
            this.m_Difference = now - this.m_Time;
            // this.m_ms = uint64( uint( now.GetMilliseconds() - this.m_Time.GetMilliseconds() ) ); nowork
            // No real mili seconds, estimated time by frame rate
            this.m_ms = uint64( double( g_Engine.time - this.m_enginetime ) + uint( ( g_Engine.frametime > 0.0f ? int( 1.0f / g_Engine.frametime ) : 0 ) ) );
            this.m_Difference.MakeAbsolute();
        }

        /**
        *   @brief Get the time diference of this chronometer.
        **/
        const TimeDifference& Difference
        {
            get const
            {
                return this.m_Difference;
            }
        }

        /**
        *   @brief Restart the chronometer time
        **/
        void Restart()
        {
            this.m_enginetime = g_Engine.time;
            this.m_Time = DateTime();
        }

        chrono()
        {
            this.Restart();
        }

        uint8 Seconds
        {
            get const
            {
                return uint8( this.Difference.GetSeconds() % 60 );
            }
        }

        uint8 Minutes
        {
            get const
            {
                return uint8( this.Difference.GetMinutes() % 60 );
            }
        }

        uint8 Hours
        {
            get const
            {
                return uint8( this.Difference.GetHours() % 24 );
            }
        }

        uint8 Days
        {
            get const
            {
                return uint8( this.Difference.GetDays() );
            }
        }

        uint64 Miliseconds
        {
            get const
            {
                return this.m_ms;
            }
        }
    }
}
