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
*   Class representing a Semantic version: https://semver.org/
**/
class SemanticVersion
{
    private
        uint m_Major;

    /**
     * Sets the major component of this version.
     *
     * @param major Non-negative major version number.
     */
    void SetMajor( uint major )
    {
        this.m_Major = major;
    }

    private
        uint m_Minor;

    /**
     * Sets the minor component of this version.
     *
     * @param minor Non-negative minor version number.
     */
    void SetMinor( uint minor )
    {
        this.m_Minor = minor;
    }

    private
        uint m_Patch;

    /**
     * Sets the patch component of this version.
     *
     * @param patch Non-negative patch version number.
     */
    void SetPatch( uint patch )
    {
        this.m_Patch = patch;
    }

    /**
     * Creates a semantic version from its three numeric components.
     *
     * @param major Major version number.
     * @param minor Minor version number.
     * @param patch Patch version number.
     */
    SemanticVersion( uint major, uint minor, uint patch )
    {
        this.SetMajor( major );
        this.SetMinor( minor );
        this.SetPatch( patch );
    }

    const uint get_Major() const
    {
        return this.m_Major;
    }

    const uint get_Minor() const
    {
        return this.m_Minor;
    }

    const uint get_Patch() const
    {
        return this.m_Patch;
    }

    /**
     * Compares all three version components for equality.
     *
     * @param other Version to compare with this instance.
     */
    bool opEquals( const SemanticVersion &in other ) const
    {
        return this.m_Major == other.m_Major &&
            this.m_Minor == other.m_Minor &&
                this.m_Patch == other.m_Patch;
    }

    /**
     * Compares versions in major, minor, then patch order.
     *
     * @param other Version to compare with this instance.
     */
    int opCmp( const SemanticVersion &in other ) const
    {
        if( this.m_Major != other.m_Major )
            return( this.m_Major < other.m_Major ) ? -1 : 1;

        if( this.m_Minor != other.m_Minor )
            return( this.m_Minor < other.m_Minor ) ? -1 : 1;

        if( this.m_Patch != other.m_Patch )
            return( this.m_Patch < other.m_Patch ) ? -1 : 1;

        return 0;
    }

    array<uint> opConv() const
    {
        return { this.m_Major, this.m_Minor, this.m_Patch };
    }

    array<int> opConv() const
    {
        return { int( this.m_Major ), int( this.m_Minor ), int( this.m_Patch ) };
    }

    /**
     * Formats this version as three numbers separated by the requested text.
     *
     * @param separator Text placed between the major, minor, and patch components.
     */
    string ToString( const string &in separator = "." ) const
    {
        string buffer;
        snprintf( buffer, "%1%2%3%2%4", this.m_Major, separator, this.m_Minor, this.m_Patch );
        return buffer;
    }
}

/**
 * Creates a semantic version from unsigned numeric components.
 *
 * @param major Major version number. Defaults to 1.
 * @param minor Minor version number. Defaults to 0.
 * @param patch Patch version number. Defaults to 0.
 */
SemanticVersion@ SemVer( uint major = 1, uint minor = 0, uint patch = 0 )
{
    return SemanticVersion( major, minor, patch );
}

/**
 * Creates a semantic version from an array of unsigned components.
 *
 * @param arr Array containing major, minor, and patch values in that order.
 *            It must contain exactly three values unless fill is true.
 * @param fill If true, missing components are filled with zero; otherwise an
 *             invalid length returns null.
 */
SemanticVersion@ SemVer( const array<uint> &in arr, bool fill = false )
{
    if( arr.length() != 3 )
    {
        if( fill )
            return SemVer( arr.length() > 0 ? arr[0] : 0, arr.length() > 1 ? arr[1] : 0, arr.length() > 2 ? arr[2] : 0 );

        g_Game.AlertMessage( at_console, "[%1] SemanticVersion: got array<uint> with size of %2 expected 3 numbers!\n", g_Module.GetModuleName(), arr.length() );
        return null;
    }
    return SemVer( arr[0], arr[1], arr[2] );
}

/**
 * Creates a semantic version from signed numeric components.
 *
 * @param major Major version number. Negative values are invalid. Defaults to 1.
 * @param minor Minor version number. Negative values are invalid. Defaults to 0.
 * @param patch Patch version number. Negative values are invalid. Defaults to 0.
 */
SemanticVersion@ SemVer( int major = 1, int minor = 0, int patch = 0 )
{
    if( major < 0 || minor < 0 || patch < 0 )
    {
        g_Game.AlertMessage( at_console, "[%1] SemanticVersion: got a negative value! \"%2\"\n", g_Module.GetModuleName(), major < 0 ? major : minor < 0 ? minor : patch );
        return null;
    }

    return SemVer( uint( major ), uint( minor ), uint( patch ) );
}

/**
 * Creates a semantic version from an array of numeric strings.
 *
 * @param arr Array containing integer-formatted major, minor, and patch values
 *            in that order. It must contain exactly three values unless fill is true.
 * @param fill If true, missing components are filled with zero; otherwise an
 *             invalid length returns null.
 */
SemanticVersion@ SemVer( const array<string> &in arr, bool fill = false )
{
    array<int> verList(3);

    if( arr.length() != 3 && !fill )
    {
        g_Game.AlertMessage( at_console, "[%1] SemanticVersion: got array<string> with size of %2 expected 3 numbers!\n", g_Module.GetModuleName(), arr.length() );
        return null;
    }

    for( uint ui = 0; ui < arr.length(); ui++ )
    {
        if( !g_Utility.IsStringInt( arr[ui] ) )
        {
            g_Game.AlertMessage( at_console, "[%1] SemanticVersion: array<string> value at index %2 is not a integer!\n", g_Module.GetModuleName(), arr.length() );
            return null;
        }
        verList[ui] = atoi( arr[ui] );
    }

    return SemVer( verList[0], verList[1], verList[2] );
}

/**
 * Parses a semantic version string into numeric components.
 *
 * @param str Version text containing major, minor, and patch components.
 * @param fill If true, missing components are filled with zero; otherwise a
 *             component count other than three returns null.
 * @param separator Text separating the components. Defaults to ".".
 */
SemanticVersion@ SemVer( const string &in str, bool fill = false, const string &in separator = "." )
{
    array<string> arr = str.Split( separator );

    if( arr.length() != 3 && !fill )
    {
        g_Game.AlertMessage( at_console, "[%1] SemanticVersion: got string with size of %2 expected 3. missing \"%3\" separators!\n", g_Module.GetModuleName(), arr.length(), separator );
        return null;
    }

    return SemVer( arr, fill );
}

/**
 * Creates a semantic version from an array of signed components.
 *
 * @param arr Array containing major, minor, and patch values in that order.
 *            It must contain exactly three values unless fill is true.
 * @param fill If true, missing components are filled with zero; otherwise an
 *             invalid length returns null.
 */
SemanticVersion@ SemVer( const array<int> &in arr, bool fill = false )
{
    if( arr.length() != 3 )
    {
        if( fill )
            return SemVer( arr.length() > 0 ? arr[0] : 0, arr.length() > 1 ? arr[1] : 0, arr.length() > 2 ? arr[2] : 0 );

        g_Game.AlertMessage( at_console, "[%1] SemanticVersion: got array<int> with size of %2 expected 3 numbers!\n", g_Module.GetModuleName(), arr.length() );
        return null;
    }

    return SemVer( arr[0] , arr[1], arr[2] );
}
