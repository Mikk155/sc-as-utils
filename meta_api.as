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
*   @brief Common metamod utilities
**/
namespace meta_api
{
    /**
    *   @brief Return whatever metamod's "aslp" plugin is installed in the server
    *   You can use the pre-processor "METAMOD_PLUGIN_ASLP" to know that. That is escentially what this method does.
    **/
    const bool IsInstalled()
    {
#if METAMOD_PLUGIN_ASLP
        if( true ) // HACK HACK: Fix Unreachable code error since we don't get the #else keyword.
            return true;
#endif
        return false;
    }

    /**
    *   @brief Notice the server if metamod's "aslp" plugin is not installed
    **/
    void NoticeInstallation()
    {
        if( !IsInstalled() )
        {
            string buffer;
            snprintf( buffer, "[Error] %1 requires metamod plugin \"aslp\" to work.\n", g_Module.GetModuleName() );
            g_EngineFuncs.ServerPrint( buffer );
            g_EngineFuncs.ServerPrint( "Some features may work poorly or not work at all.\n" );
            g_EngineFuncs.ServerPrint( "Install metamod at: https://github.com/Mikk155/Sven-Co-op\n" );
        }
    }
}
