"""Trim and optionally inline the mikk155 AngelScript submodule."""

from __future__ import annotations;

import argparse;
import json;
import re;
import sys;
from pathlib import Path;

class IncludeError( ValueError ):
    """Raised when an include cannot be resolved."""

parser: argparse.ArgumentParser;

SUBMODULE_URL: str = "https://github.com/Mikk155/sc-as-utils";

def InlineList( value: str ) -> list[str]:

    value = value.strip();

    if len( value ) >= 2 and value[0] == value[-1] and value[0] in ( "'", '"' ):
        value = value[1:-1];

    try:
        parsed: object = json.loads( value );
    except json.JSONDecodeError:
        if value.startswith( "[" ) and value.endswith( "]" ):
            value = value[1:-1];

        return [
            item.strip().strip( "'\"" )
            for item in value.split( "," )
            if item.strip()
        ];

    if not isinstance( parsed, list ) or not all( isinstance( item, str ) for item in parsed ):
        raise argparse.ArgumentTypeError( "inline must be a comma-separated list or JSON string list" );

    return [ item.strip() for item in parsed if item.strip() ];

def LicenseHeader( submodule: Path ) -> str:

    licensePath: Path = Path( submodule / "LICENSE" );
    lines: list[str] = licensePath.read_text( encoding="utf-8" ).splitlines( keepends=True );

    headerLines: list[str] = [ "/**\n" ];

    for line in lines:
        line = line if line.endswith( "\n" ) else f"{line}\n";
        headerLines.append( f"*   {line}" if line.strip() else "*\n" );

    headerLines.append( "**/\n\n" );

    return "".join( headerLines );

def RemoveLicenseHeader( content: str ) -> str:

    match: re.Match[str] | None = re.match( r"^\s*/\*.*?Copyright.*?\*/", content, re.DOTALL );

    if match:
        return content[ match.end(): ].lstrip( "\r\n" );

    return content;

def FormatScript( source: Path, licenseHeader: str ) -> str:

    content: str = source.read_text( encoding="utf-8" ).replace( "\r\n", "\n" ).replace( "\r", "\n" );
    content = RemoveLicenseHeader( content );
    content = content.replace( "\t", "    " ).rstrip( "\n" );

    return f"{licenseHeader}{content}\n";

def StripComments( content: str ) -> str:

    result: list[str] = [];
    index: int = 0;
    inString: str | None = None;
    inComment: str | None = None;

    while index < len( content ):

        character: str = content[index];
        nextCharacter: str = content[index + 1] if index + 1 < len( content ) else "";

        if inComment == "line":
            if character in "\r\n":
                inComment = None;
                result.append( character );
            index += 1;
            continue;

        if inComment == "block":
            if character == "*" and nextCharacter == "/":
                inComment = None;
                result.append( " " );
                index += 2;
                continue;
            index += 1;
            continue;

        if inString is not None:
            result.append( character );
            if character == "\\" and nextCharacter:
                result.append( nextCharacter );
                index += 2;
                continue;
            if character == inString:
                inString = None;
            index += 1;
            continue;

        if character in ( '"', "'" ):
            inString = character;
            result.append( character );
            index += 1;
            continue;

        if character == "/" and nextCharacter == "/":
            inComment = "line";
            index += 2;
            continue;

        if character == "/" and nextCharacter == "*":
            inComment = "block";
            index += 2;
            continue;

        result.append( character );
        index += 1;

    return "".join( result );

def RemoveEmptyLines( content: str ) -> str:

    return "".join(
        line for line in content.splitlines( keepends=True )
        if line.strip()
    );

def SubmoduleMarker( prefix: str, source: Path, submodule: Path ) -> str:

    relativePath: str = source.relative_to( submodule ).as_posix();
    return f"// {prefix} {SUBMODULE_URL}/{relativePath}\n";

def IncludeTarget( source: Path, include: str ) -> Path:

    base: Path = Path( source.parent / include ).resolve();
    candidates: list[Path] = [ base ];

    if base.suffix == "":
        candidates.append( base.with_suffix( ".as" ) );

    for candidate in candidates:
        if candidate.is_file():
            return candidate;

    raise IncludeError( f"{source}: cannot resolve #include {include!r}" );

def IncludesIn( source: Path, reInclude: re.Pattern ) -> list[tuple[int, str]]:

    result: list[tuple[int, str]] = []

    for lineNumber, line in enumerate( source.read_text( encoding="utf-8" ).splitlines(), start=1 ):

        match: re.Match[str] | None = reInclude.match( line )

        if match:
            result.append( ( lineNumber, match.group(1) ) )

    return result


def CollectDependencies( source: Path, submodule: Path, reInclude: re.Pattern ) -> tuple[list[Path], set[Path]]:

    visited: list[Path] = [];
    visitedSet: set[Path] = set();

    includedSubmoduleFiles: set[Path] = set();

    def visit( current: Path ) -> None:

        current = current.resolve();

        if current in visitedSet:
            return;

        visitedSet.add( current );
        visited.append( current );

        for lineNumber, include in IncludesIn( current, reInclude ):

            try:
                target = IncludeTarget( current, include );
            except IncludeError as error:
                raise IncludeError( f"{error} (line {lineNumber})" ) from error;
            if target.is_relative_to( submodule):
                includedSubmoduleFiles.add( target );

            visit( target );

    visit( source );

    return visited, includedSubmoduleFiles;

def CollectProtectedDependencies(
    source: Path,
    submodule: Path,
    reInclude: re.Pattern,
    inlineFiles: set[Path],
) -> set[Path]:

    visited: set[Path] = set();
    protected: set[Path] = set();

    def visit( current: Path ) -> None:

        current = current.resolve();

        if current in visited:
            return;

        visited.add( current );

        for lineNumber, include in IncludesIn( current, reInclude ):

            try:
                target: Path = IncludeTarget( current, include );
            except IncludeError as error:
                raise IncludeError( f"{error} (line {lineNumber})" ) from error;

            if target.is_relative_to( submodule ):

                target = target.resolve();

                if target in inlineFiles:
                    continue;

                protected.add( target );

            visit( target );

    visit( source );

    return protected;

def ResolveInlineFiles( names: list[str], submodule: Path ) -> set[Path]:

    resolved: set[Path] = set();

    for name in names:
        candidate: Path = ( submodule / name ).resolve();

        if candidate.suffix == "":
            candidate = candidate.with_suffix( ".as" );

        if not candidate.is_file() or not candidate.is_relative_to( submodule ):
            raise IncludeError( f"cannot resolve inline file {name!r}" );

        resolved.add( candidate );

    return resolved;

def InlineSources(
    reachableFiles: list[Path],
    submodule: Path,
    reInclude: re.Pattern,
    inlineFiles: set[Path],
    protectedFiles: set[Path],
    workspace: Path,
    dryRun: bool,
) -> set[Path]:

    reachableSources: list[Path] = [
        path for path in reachableFiles if not path.is_relative_to( submodule )
    ];
    contained: set[Path] = set();

    for reachableSource in reachableSources:

        rendered: str = RenderContainer(
            reachableSource,
            submodule,
            reInclude,
            contained,
            inlineFiles,
            protectedFiles,
        );

        if rendered == reachableSource.read_text( encoding="utf-8" ):
            continue;

        print( f"Inline: {reachableSource.relative_to( workspace )}" );

        if not dryRun:
            reachableSource.write_text( rendered, encoding="utf-8", newline="" );

    return contained;

def CleanupSubmodule(
    submodule: Path,
    dependencies: set[Path],
    contained: set[Path],
    candidates: set[Path],
    workspace: Path,
    dryRun: bool,
) -> int:

    removeFiles: set[Path] = ( candidates - dependencies ) | contained;

    removeFiles.update(
        path for path in (
            submodule / ".gitignore",
            submodule / ".gitattributes",
            submodule / "AUTHORS.md",
            submodule / "CHANGELOG.md",
            submodule / "Doxyfile",
        )
        if path.exists()
    );

    tools: Path = submodule / "tools";
    if tools.exists():
        removeFiles.update( path for path in tools.rglob( "*" ) if path.is_file() );

    if not ( dependencies - contained ):
        removeFiles.update(
            path for path in (
                submodule / "LICENSE",
                submodule / "README.md",
            )
            if path.exists()
        );

    for path in sorted( removeFiles, key=lambda item: len( item.parts ), reverse=True ):

        print( f"Remove: {path.relative_to( workspace )}" );

        if not dryRun and path.exists():
            path.unlink();

    emptyDirectories: list[Path] = sorted(
        (
            path for path in submodule.rglob( "*" )
            if path.is_dir() and path.name != ".git"
        ),
        key=lambda item: len( item.parts ),
        reverse=True,
    );

    for path in emptyDirectories:

        if any( path.iterdir() ):
            continue;

        print( f"Remove directory: {path.relative_to( workspace )}" );

        if not dryRun:
            path.rmdir();

    if not any( submodule.rglob( "*.as" ) ):
        print( f"Submodule has no AngelScript files: {submodule.relative_to( workspace )}" );

    return len( removeFiles );


def RenderContainer(
    source: Path,
    submodule: Path,
    reInclude: re.Pattern,
    contained: set[Path],
    inlineFiles: set[Path],
    protectedFiles: set[Path],
    stack: tuple[Path, ...] = (),
) -> str:

    source = source.resolve();

    if source in stack:
        chain = " -> ".join( str( item ) for item in ( *stack, source ) );
        raise IncludeError( f"cyclic include detected: {chain}" );

    content: str = source.read_text( encoding="utf-8" );

    if source.is_relative_to( submodule ):
        content = StripComments( content );
        content = RemoveEmptyLines( content );

    output: list[str] = [];

    for line in content.splitlines( keepends=True ):

        match: re.Match[str] | None = reInclude.match( line );

        if not match:
            output.append( line );
            continue;

        target = IncludeTarget( source, match.group(1) );

        if target.is_relative_to( submodule ):
            target = target.resolve();

            if source.is_relative_to( submodule ) and target in protectedFiles:
                continue;

            if (
                not source.is_relative_to( submodule )
                and target not in inlineFiles
            ):
                output.append( line );
                continue;

            if target in contained:
                continue;

            contained.add( target );
            renderedTarget: str = RenderContainer(
                target,
                submodule,
                reInclude,
                contained,
                inlineFiles,
                protectedFiles,
                ( *stack, source ),
            ).strip();

            if not renderedTarget:
                contained.remove( target );
                continue;

            output.append(
                SubmoduleMarker( "Start", target, submodule )
            );
            output.append(
                f"{renderedTarget}\n"
            );
            output.append( SubmoduleMarker( "End", target, submodule ) );
        else:
            output.append( line );

    return "".join( output );

def Main() -> int:

    arguments: argparse.Namespace = parser.parse_args();
    workspace: Path = Path.cwd().resolve();

    submodule: Path = Path( Path( __file__ ).resolve().parent.parent ).resolve();

    if( arguments.format ):

        licenseHeader: str = LicenseHeader( submodule );

        for source in sorted( submodule.rglob( "*.as" ) ):

            formatted: str = FormatScript( source, licenseHeader );
            current: str = source.read_text( encoding="utf-8" ).replace( "\r\n", "\n" ).replace( "\r", "\n" );

            if formatted == current:
                continue;

            print( f"Format: {source.relative_to( workspace )}" );

            if not arguments.dry_run:
                source.write_text( formatted, encoding="utf-8", newline="" );

        return 0;

    if( arguments.source ):

        source: Path = Path( workspace / arguments.source ).resolve()

        reInclude: re.Pattern = re.compile( r'^\s*#include\s+["<]([^">]+)[">]' );

        reachableFiles, dependencies = CollectDependencies( source, submodule, reInclude );

        candidates = {
            path.resolve()
            for path in submodule.rglob( "*.as" )
        };

        unused: list[Path] = sorted( candidates - dependencies );

        contained: set[Path] = set();

        if arguments.inline_all or arguments.inline:

            inlineFiles: set[Path] = dependencies;

            if arguments.inline:
                inlineFiles = ResolveInlineFiles( arguments.inline, submodule );

            protectedFiles: set[Path] = CollectProtectedDependencies(
                source,
                submodule,
                reInclude,
                inlineFiles,
            );

            contained = InlineSources(
                reachableFiles,
                submodule,
                reInclude,
                inlineFiles,
                protectedFiles,
                workspace,
                arguments.dry_run,
            );

        CleanupSubmodule(
            submodule,
            dependencies,
            contained,
            candidates,
            workspace,
            arguments.dry_run,
        );

        print( f"Included files: {len( dependencies )}" );
        print( f"Unused files: {len( unused )}" );

        return 0;

    return 2;

if __name__ == "__main__":

    try:

        parser = argparse.ArgumentParser(
            description=(
                "Various tools for the submodule."
            )
        );

        parser.add_argument(
            "-source",
            type=Path,
            help="Entry-point script, relative to the workspace.",
        );

        parser.add_argument(
            "--inline-all",
            action="store_true",
            help="Inline all mikk155 files at their include sites.",
        );

        parser.add_argument(
            "-inline",
            type=InlineList,
            help="Inline selected files as comma-separated or JSON values.",
        );

        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="Report files that would be removed without changing anything.",
        );

        parser.add_argument(
            "--format",
            action="store_true",
            help="Format submodule files.",
        );

        result: int = Main();

        if result == 2:
            parser.print_help( file=sys.stderr );

        sys.exit( result );

    except Exception as error:

        print( f"Error: {error}", file=sys.stderr );
        sys.exit(1);
