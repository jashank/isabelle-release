(*:maxLineLen=78:*)

theory JEdit
imports Base
begin

chapter \<open>Introduction\<close>

section \<open>Concepts and terminology\<close>

text \<open>
  Isabelle/jEdit is a Prover IDE that integrates \<^emph>\<open>parallel proof checking\<close>
  @{cite "Wenzel:2009" and "Wenzel:2013:ITP"} with \<^emph>\<open>asynchronous user
  interaction\<close> @{cite "Wenzel:2010" and "Wenzel:2012:UITP-EPTCS" and
  "Wenzel:2014:ITP-PIDE" and "Wenzel:2014:UITP"}, based on a document-oriented
  approach to \<^emph>\<open>continuous proof processing\<close> @{cite "Wenzel:2011:CICM" and
  "Wenzel:2012"}. Many concepts and system components are fit together in
  order to make this work. The main building blocks are as follows.

    \<^descr>[PIDE] is a general framework for Prover IDEs based on Isabelle/Scala. It
    is built around a concept of parallel and asynchronous document
    processing, which is supported natively by the parallel proof engine that
    is implemented in Isabelle/ML. The traditional prover command loop is
    given up; instead there is direct support for editing of source text, with
    rich formal markup for GUI rendering.

    \<^descr>[Isabelle/ML] is the implementation and extension language of Isabelle,
    see also @{cite "isabelle-implementation"}. It is integrated into the
    logical context of Isabelle/Isar and allows to manipulate logical entities
    directly. Arbitrary add-on tools may be implemented for object-logics such
    as Isabelle/HOL.

    \<^descr>[Isabelle/Scala] is the system programming language of Isabelle. It
    extends the pure logical environment of Isabelle/ML towards the ``real
    world'' of graphical user interfaces, text editors, IDE frameworks, web
    services etc. Special infrastructure allows to transfer algebraic
    datatypes and formatted text easily between ML and Scala, using
    asynchronous protocol commands.

    \<^descr>[jEdit] is a sophisticated text editor implemented in Java.\<^footnote>\<open>@{url
    "http://www.jedit.org"}\<close> It is easily extensible by plugins written in
    languages that work on the JVM, e.g.\ Scala\<^footnote>\<open>@{url
    "http://www.scala-lang.org"}\<close>.

    \<^descr>[Isabelle/jEdit] is the main example application of the PIDE framework
    and the default user-interface for Isabelle. It targets both beginners and
    experts. Technically, Isabelle/jEdit combines a slightly modified version
    of the jEdit code base with a special plugin for Isabelle, integrated as
    standalone application for the main operating system platforms: Linux,
    Windows, Mac OS X.

  The subtle differences of Isabelle/ML versus Standard ML, Isabelle/Scala
  versus Scala, Isabelle/jEdit versus jEdit need to be taken into account when
  discussing any of these PIDE building blocks in public forums, mailing
  lists, or even scientific publications.
\<close>


section \<open>The Isabelle/jEdit Prover IDE\<close>

text \<open>
  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.333]{isabelle-jedit}
  \end{center}
  \caption{The Isabelle/jEdit Prover IDE}
  \label{fig:isabelle-jedit}
  \end{figure}

  Isabelle/jEdit (\figref{fig:isabelle-jedit}) consists of some plugins for
  the jEdit text editor, while preserving its general look-and-feel as far as
  possible. The main plugin is called ``Isabelle'' and has its own menu
  \<^emph>\<open>Plugins~/ Isabelle\<close> with access to several panels (see also
  \secref{sec:dockables}), as well as \<^emph>\<open>Plugins~/ Plugin Options~/ Isabelle\<close>
  (see also \secref{sec:options}).

  The options allow to specify a logic session name --- the same selector is
  accessible in the \<^emph>\<open>Theories\<close> panel (\secref{sec:theories}). On application
  startup, the selected logic session image is provided automatically by the
  Isabelle build tool @{cite "isabelle-system"}: if it is absent or outdated
  wrt.\ its sources, the build process updates it before entering the Prover
  IDE. Change of the logic session within Isabelle/jEdit requires a restart of
  the whole application.

  \<^medskip>
  The main job of the Prover IDE is to manage sources and their changes,
  taking the logical structure as a formal document into account (see also
  \secref{sec:document-model}). The editor and the prover are connected
  asynchronously in a lock-free manner. The prover is free to organize the
  checking of the formal text in parallel on multiple cores, and provides
  feedback via markup, which is rendered in the editor via colors, boxes,
  squiggly underlines, hyperlinks, popup windows, icons, clickable output etc.

  Using the mouse together with the modifier key \<^verbatim>\<open>CONTROL\<close> (Linux, Windows)
  or \<^verbatim>\<open>COMMAND\<close> (Mac OS X) exposes additional formal content via tooltips
  and/or hyperlinks (see also \secref{sec:tooltips-hyperlinks}). Output (in
  popups etc.) may be explored recursively, using the same techniques as in
  the editor source buffer.

  Thus the Prover IDE gives an impression of direct access to formal content
  of the prover within the editor, but in reality only certain aspects are
  exposed, according to the possibilities of the prover and its many add-on
  tools.
\<close>


subsection \<open>Documentation\<close>

text \<open>
  The \<^emph>\<open>Documentation\<close> panel of Isabelle/jEdit provides access to the standard
  Isabelle documentation: PDF files are opened by regular desktop operations
  of the underlying platform. The section ``Original jEdit Documentation''
  contains the original \<^emph>\<open>User's Guide\<close> of this sophisticated text editor. The
  same is accessible via the \<^verbatim>\<open>Help\<close> menu or \<^verbatim>\<open>F1\<close> keyboard shortcut, using
  the built-in HTML viewer of Java/Swing. The latter also includes
  \<^emph>\<open>Frequently Asked Questions\<close> and documentation of individual plugins.

  Most of the information about generic jEdit is relevant for Isabelle/jEdit
  as well, but one needs to keep in mind that defaults sometimes differ, and
  the official jEdit documentation does not know about the Isabelle plugin
  with its support for continuous checking of formal source text: jEdit is a
  plain text editor, but Isabelle/jEdit is a Prover IDE.
\<close>


subsection \<open>Plugins\<close>

text \<open>
  The \<^emph>\<open>Plugin Manager\<close> of jEdit allows to augment editor functionality by JVM
  modules (jars) that are provided by the central plugin repository, which is
  accessible via various mirror sites.

  Connecting to the plugin server-infrastructure of the jEdit project allows
  to update bundled plugins or to add further functionality. This needs to be
  done with the usual care for such an open bazaar of contributions. Arbitrary
  combinations of add-on features are apt to cause problems. It is advisable
  to start with the default configuration of Isabelle/jEdit and develop some
  understanding how it is supposed to work, before loading additional plugins
  at a grand scale.

  \<^medskip>
  The main \<^emph>\<open>Isabelle\<close> plugin is an integral part of Isabelle/jEdit and needs
  to remain active at all times! A few additional plugins are bundled with
  Isabelle/jEdit for convenience or out of necessity, notably \<^emph>\<open>Console\<close> with
  its Isabelle/Scala sub-plugin (\secref{sec:scala-console}) and \<^emph>\<open>SideKick\<close>
  with some Isabelle-specific parsers for document tree structure
  (\secref{sec:sidekick}). The \<^emph>\<open>Navigator\<close> plugin is particularly important
  for hyperlinks within the formal document-model
  (\secref{sec:tooltips-hyperlinks}). Further plugins (e.g.\ \<^emph>\<open>ErrorList\<close>,
  \<^emph>\<open>Code2HTML\<close>) are included to saturate the dependencies of bundled plugins,
  but have no particular use in Isabelle/jEdit.
\<close>


subsection \<open>Options \label{sec:options}\<close>

text \<open>
  Both jEdit and Isabelle have distinctive management of persistent options.

  Regular jEdit options are accessible via the dialogs \<^emph>\<open>Utilities~/ Global
  Options\<close> or \<^emph>\<open>Plugins~/ Plugin Options\<close>, with a second chance to flip the
  two within the central options dialog. Changes are stored in
  @{file_unchecked "$ISABELLE_HOME_USER/jedit/properties"} and
  @{file_unchecked "$ISABELLE_HOME_USER/jedit/keymaps"}.

  Isabelle system options are managed by Isabelle/Scala and changes are stored
  in @{file_unchecked "$ISABELLE_HOME_USER/etc/preferences"}, independently of
  other jEdit properties. See also @{cite "isabelle-system"}, especially the
  coverage of sessions and command-line tools like @{tool build} or @{tool
  options}.

  Those Isabelle options that are declared as \<^bold>\<open>public\<close> are configurable in
  Isabelle/jEdit via \<^emph>\<open>Plugin Options~/ Isabelle~/ General\<close>. Moreover, there
  are various options for rendering of document content, which are
  configurable via \<^emph>\<open>Plugin Options~/ Isabelle~/ Rendering\<close>. Thus \<^emph>\<open>Plugin
  Options~/ Isabelle\<close> in jEdit provides a view on a subset of Isabelle system
  options. Note that some of these options affect general parameters that are
  relevant outside Isabelle/jEdit as well, e.g.\ @{system_option threads} or
  @{system_option parallel_proofs} for the Isabelle build tool @{cite
  "isabelle-system"}, but it is possible to use the settings variable
  @{setting ISABELLE_BUILD_OPTIONS} to change defaults for batch builds
  without affecting Isabelle/jEdit.

  The jEdit action @{action_def isabelle.options} opens the options dialog for
  the Isabelle plugin; it can be mapped to editor GUI elements as usual.

  \<^medskip>
  Options are usually loaded on startup and saved on shutdown of
  Isabelle/jEdit. Editing the machine-generated @{file_unchecked
  "$ISABELLE_HOME_USER/jedit/properties"} or @{file_unchecked
  "$ISABELLE_HOME_USER/etc/preferences"} manually while the application is
  running is likely to cause surprise due to lost update!
\<close>


subsection \<open>Keymaps\<close>

text \<open>
  Keyboard shortcuts used to be managed as jEdit properties in the past, but
  recent versions (2013) have a separate concept of \<^emph>\<open>keymap\<close> that is
  configurable via \<^emph>\<open>Global Options~/ Shortcuts\<close>. The \<^verbatim>\<open>imported\<close> keymap is
  derived from the initial environment of properties that is available at the
  first start of the editor; afterwards the keymap file takes precedence.

  This is relevant for Isabelle/jEdit due to various fine-tuning of default
  properties, and additional keyboard shortcuts for Isabelle-specific
  functionality. Users may change their keymap later, but need to copy some
  keyboard shortcuts manually (see also @{file_unchecked
  "$ISABELLE_HOME_USER/jedit/keymaps"} versus \<^verbatim>\<open>shortcut\<close> properties in @{file
  "$ISABELLE_HOME/src/Tools/jEdit/src/jEdit.props"}).
\<close>


section \<open>Command-line invocation \label{sec:command-line}\<close>

text \<open>
  Isabelle/jEdit is normally invoked as standalone application, with
  platform-specific executable wrappers for Linux, Windows, Mac OS X.
  Nonetheless it is occasionally useful to invoke the Prover IDE on the
  command-line, with some extra options and environment settings as explained
  below. The command-line usage of @{tool_def jedit} is as follows:
  @{verbatim [display]
\<open>Usage: isabelle jedit [OPTIONS] [FILES ...]

  Options are:
    -J OPTION    add JVM runtime option
    -b           build only
    -d DIR       include session directory
    -f           fresh build
    -j OPTION    add jEdit runtime option
    -l NAME      logic image name
    -m MODE      add print mode for output
    -n           no build of session image on startup
    -s           system build mode for session image

  Start jEdit with Isabelle plugin setup and open FILES
  (default "$USER_HOME/Scratch.thy" or ":" for empty buffer).\<close>}

  The \<^verbatim>\<open>-l\<close> option specifies the session name of the logic image to be used
  for proof processing. Additional session root directories may be included
  via option \<^verbatim>\<open>-d\<close> to augment that name space of @{tool build} @{cite
  "isabelle-system"}.

  By default, the specified image is checked and built on demand. The \<^verbatim>\<open>-s\<close>
  option determines where to store the result session image of @{tool build}.
  The \<^verbatim>\<open>-n\<close> option bypasses the implicit build process for the selected
  session image.

  The \<^verbatim>\<open>-m\<close> option specifies additional print modes for the prover process.
  Note that the system option @{system_option_ref jedit_print_mode} allows to
  do the same persistently (e.g.\ via the \<^emph>\<open>Plugin Options\<close> dialog of
  Isabelle/jEdit), without requiring command-line invocation.

  The \<^verbatim>\<open>-J\<close> and \<^verbatim>\<open>-j\<close> options allow to pass additional low-level options to
  the JVM or jEdit, respectively. The defaults are provided by the Isabelle
  settings environment @{cite "isabelle-system"}, but note that these only
  work for the command-line tool described here, and not the regular
  application.

  The \<^verbatim>\<open>-b\<close> and \<^verbatim>\<open>-f\<close> options control the self-build mechanism of
  Isabelle/jEdit. This is only relevant for building from sources, which also
  requires an auxiliary \<^verbatim>\<open>jedit_build\<close> component from @{url
  "http://isabelle.in.tum.de/components"}. The official Isabelle release
  already includes a pre-built version of Isabelle/jEdit. \<close>


chapter \<open>Augmented jEdit functionality\<close>

section \<open>GUI rendering\<close>

subsection \<open>Look-and-feel \label{sec:look-and-feel}\<close>

text \<open>
  jEdit is a Java/AWT/Swing application with some ambition to support
  ``native'' look-and-feel on all platforms, within the limits of what Oracle
  as Java provider and major operating system distributors allow (see also
  \secref{sec:problems}).

  Isabelle/jEdit enables platform-specific look-and-feel by default as
  follows.

    \<^descr>[Linux:] The platform-independent \<^emph>\<open>Metal\<close> is used by default.

    \<^emph>\<open>GTK+\<close> also works under the side-condition that the overall GTK theme is
    selected in a Swing-friendly way.\<^footnote>\<open>GTK support in Java/Swing was once
    marketed aggressively by Sun, but never quite finished. Today (2015) it is
    lagging behind further development of Swing and GTK. The graphics
    rendering performance can be worse than for other Swing look-and-feels.
    Nonetheless it has its uses for displays with very high resolution (such
    as ``4K'' or ``UHD'' models), because the rendering by the external
    library is subject to global system settings for font scaling.\<close>

    \<^descr>[Windows:] Regular \<^emph>\<open>Windows\<close> is used by default, but \<^emph>\<open>Windows Classic\<close>
    also works.

    \<^descr>[Mac OS X:] Regular \<^emph>\<open>Mac OS X\<close> is used by default.

    The bundled \<^emph>\<open>MacOSX\<close> plugin provides various functions that are expected
    from applications on that particular platform: quit from menu or dock,
    preferences menu, drag-and-drop of text files on the application,
    full-screen mode for main editor windows. It is advisable to have the
    \<^emph>\<open>MacOSX\<close> plugin enabled all the time on that platform.

  Users may experiment with different look-and-feels, but need to keep in mind
  that this extra variance of GUI functionality is unlikely to work in
  arbitrary combinations. The platform-independent \<^emph>\<open>Metal\<close> and \<^emph>\<open>Nimbus\<close>
  should always work. The historic \<^emph>\<open>CDE/Motif\<close> should be ignored.

  After changing the look-and-feel in \<^emph>\<open>Global Options~/ Appearance\<close>, it is
  advisable to restart Isabelle/jEdit in order to take full effect.
\<close>


subsection \<open>Displays with very high resolution \label{sec:hdpi}\<close>

text \<open>
  Many years ago, displays with $1024 \times 768$ or $1280 \times 1024$ pixels
  were considered ``high resolution'' and bitmap fonts with 12 or 14 pixels as
  adequate for text rendering. Today (2015), we routinely see ``Full HD''
  monitors at $1920 \times 1080$ pixels, and occasionally ``Ultra HD'' at
  $3840 \times 2160$ or more, but GUI rendering did not really progress beyond
  the old standards.

  Isabelle/jEdit defaults are a compromise for reasonable out-of-the box
  results on common platforms and medium resolution displays (e.g.\ the ``Full
  HD'' category). Subsequently there are further hints to improve on that.

  \<^medskip>
  The \<^bold>\<open>operating-system platform\<close> usually provides some configuration for
  global scaling of text fonts, e.g.\ $120\%$--$250\%$ on Windows. Changing
  that only has a partial effect on GUI rendering; satisfactory display
  quality requires further adjustments.

  \<^medskip>
  The Isabelle/jEdit \<^bold>\<open>application\<close> and its plugins provide various font
  properties that are summarized below.

    \<^item> \<^emph>\<open>Global Options / Text Area / Text font\<close>: the main text area font,
    which is also used as reference point for various derived font sizes,
    e.g.\ the Output panel (\secref{sec:output}).

    \<^item> \<^emph>\<open>Global Options / Gutter / Gutter font\<close>: the font for the gutter area
    left of the main text area, e.g.\ relevant for display of line numbers
    (disabled by default).

    \<^item> \<^emph>\<open>Global Options / Appearance / Button, menu and label font\<close> as well as
    \<^emph>\<open>List and text field font\<close>: this specifies the primary and secondary font
    for the traditional \<^emph>\<open>Metal\<close> look-and-feel (\secref{sec:look-and-feel}),
    which happens to scale better than newer ones like \<^emph>\<open>Nimbus\<close>.

    \<^item> \<^emph>\<open>Plugin Options / Isabelle / General / Reset Font Size\<close>: the main text
    area font size for action @{action_ref "isabelle.reset-font-size"}, e.g.\
    relevant for quick scaling like in major web browsers.

    \<^item> \<^emph>\<open>Plugin Options / Console / General / Font\<close>: the console window font,
    e.g.\ relevant for Isabelle/Scala command-line.

  In \figref{fig:isabelle-jedit-hdpi} the \<^emph>\<open>Metal\<close> look-and-feel is configured
  with custom fonts at 30 pixels, and the main text area and console at 36
  pixels. Despite the old-fashioned appearance of \<^emph>\<open>Metal\<close>, this leads to
  decent rendering quality on all platforms.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[width=\textwidth]{isabelle-jedit-hdpi}
  \end{center}
  \caption{Metal look-and-feel with custom fonts for very high resolution}
  \label{fig:isabelle-jedit-hdpi}
  \end{figure}

  On Linux, it is also possible to use \<^emph>\<open>GTK+\<close> with a suitable theme and
  global font scaling. On Mac OS X, the default setup for ``Retina'' displays
  should work adequately with the native look-and-feel.
\<close>


section \<open>Dockable windows \label{sec:dockables}\<close>

text \<open>
  In jEdit terminology, a \<^emph>\<open>view\<close> is an editor window with one or more \<^emph>\<open>text
  areas\<close> that show the content of one or more \<^emph>\<open>buffers\<close>. A regular view may
  be surrounded by \<^emph>\<open>dockable windows\<close> that show additional information in
  arbitrary format, not just text; a \<^emph>\<open>plain view\<close> does not allow dockables.
  The \<^emph>\<open>dockable window manager\<close> of jEdit organizes these dockable windows,
  either as \<^emph>\<open>floating\<close> windows, or \<^emph>\<open>docked\<close> panels within one of the four
  margins of the view. There may be any number of floating instances of some
  dockable window, but at most one docked instance; jEdit actions that address
  \<^emph>\<open>the\<close> dockable window of a particular kind refer to the unique docked
  instance.

  Dockables are used routinely in jEdit for important functionality like
  \<^emph>\<open>HyperSearch Results\<close> or the \<^emph>\<open>File System Browser\<close>. Plugins often provide
  a central dockable to access their key functionality, which may be opened by
  the user on demand. The Isabelle/jEdit plugin takes this approach to the
  extreme: its plugin menu provides the entry-points to many panels that are
  managed as dockable windows. Some important panels are docked by default,
  e.g.\ \<^emph>\<open>Documentation\<close>, \<^emph>\<open>Output\<close>, \<^emph>\<open>Query\<close>, but the user can change this
  arrangement easily and persistently.

  Compared to plain jEdit, dockable window management in Isabelle/jEdit is
  slightly augmented according to the the following principles:

  \<^item> Floating windows are dependent on the main window as \<^emph>\<open>dialog\<close> in
  the sense of Java/AWT/Swing. Dialog windows always stay on top of the view,
  which is particularly important in full-screen mode. The desktop environment
  of the underlying platform may impose further policies on such dependent
  dialogs, in contrast to fully independent windows, e.g.\ some window
  management functions may be missing.

  \<^item> Keyboard focus of the main view vs.\ a dockable window is carefully
  managed according to the intended semantics, as a panel mainly for output or
  input. For example, activating the \<^emph>\<open>Output\<close> (\secref{sec:output}) panel
  via the dockable window manager returns keyboard focus to the main text
  area, but for \<^emph>\<open>Query\<close> (\secref{sec:query}) the focus is given to the
  main input field of that panel.

  \<^item> Panels that provide their own text area for output have an additional
  dockable menu item \<^emph>\<open>Detach\<close>. This produces an independent copy of the
  current output as a floating \<^emph>\<open>Info\<close> window, which displays that content
  independently of ongoing changes of the PIDE document-model. Note that
  Isabelle/jEdit popup windows (\secref{sec:tooltips-hyperlinks}) provide a
  similar \<^emph>\<open>Detach\<close> operation as an icon.
\<close>


section \<open>Isabelle symbols \label{sec:symbols}\<close>

text \<open>
  Isabelle sources consist of \<^emph>\<open>symbols\<close> that extend plain ASCII to allow
  infinitely many mathematical symbols within the formal sources. This works
  without depending on particular encodings and varying Unicode
  standards.\<^footnote>\<open>Raw Unicode characters within formal sources would compromise
  portability and reliability in the face of changing interpretation of
  special features of Unicode, such as Combining Characters or Bi-directional
  Text.\<close> See also @{cite "Wenzel:2011:CICM"}.

  For the prover back-end, formal text consists of ASCII characters that are
  grouped according to some simple rules, e.g.\ as plain ``\<^verbatim>\<open>a\<close>'' or symbolic
  ``\<^verbatim>\<open>\<alpha>\<close>''. For the editor front-end, a certain subset of symbols is rendered
  physically via Unicode glyphs, in order to show ``\<^verbatim>\<open>\<alpha>\<close>'' as ``\<open>\<alpha>\<close>'', for
  example. This symbol interpretation is specified by the Isabelle system
  distribution in @{file "$ISABELLE_HOME/etc/symbols"} and may be augmented by
  the user in @{file_unchecked "$ISABELLE_HOME_USER/etc/symbols"}.

  The appendix of @{cite "isabelle-isar-ref"} gives an overview of the
  standard interpretation of finitely many symbols from the infinite
  collection. Uninterpreted symbols are displayed literally, e.g.\
  ``\<^verbatim>\<open>\<foobar>\<close>''. Overlap of Unicode characters used in symbol
  interpretation with informal ones (which might appear e.g.\ in comments)
  needs to be avoided. Raw Unicode characters within prover source files
  should be restricted to informal parts, e.g.\ to write text in non-latin
  alphabets in comments.
\<close>

paragraph \<open>Encoding.\<close>
text \<open>Technically, the Unicode view on Isabelle symbols is an \<^emph>\<open>encoding\<close>
  called \<^verbatim>\<open>UTF-8-Isabelle\<close> in jEdit (not in the underlying JVM). It is
  provided by the Isabelle/jEdit plugin and enabled by default for all source
  files. Sometimes such defaults are reset accidentally, or malformed UTF-8
  sequences in the text force jEdit to fall back on a different encoding like
  \<^verbatim>\<open>ISO-8859-15\<close>. In that case, verbatim ``\<^verbatim>\<open>\<alpha>\<close>'' will be shown in the text
  buffer instead of its Unicode rendering ``\<open>\<alpha>\<close>''. The jEdit menu operation
  \<^emph>\<open>File~/ Reload with Encoding~/ UTF-8-Isabelle\<close> helps to resolve such
  problems (after repairing malformed parts of the text).
\<close>

paragraph \<open>Font.\<close>
text \<open>Correct rendering via Unicode requires a font that contains glyphs for
  the corresponding codepoints. Most system fonts lack that, so Isabelle/jEdit
  prefers its own application font \<^verbatim>\<open>IsabelleText\<close>, which ensures that
  standard collection of Isabelle symbols are actually seen on the screen (or
  printer).

  Note that a Java/AWT/Swing application can load additional fonts only if
  they are not installed on the operating system already! Some outdated
  version of \<^verbatim>\<open>IsabelleText\<close> that happens to be provided by the operating
  system would prevent Isabelle/jEdit to use its bundled version. This could
  lead to missing glyphs (black rectangles), when the system version of
  \<^verbatim>\<open>IsabelleText\<close> is older than the application version. This problem can be
  avoided by refraining to ``install'' any version of \<^verbatim>\<open>IsabelleText\<close> in the
  first place, although it is occasionally tempting to use the same font in
  other applications.
\<close>

paragraph \<open>Input methods.\<close>
text \<open>In principle, Isabelle/jEdit could delegate the problem to produce
  Isabelle symbols in their Unicode rendering to the underlying operating
  system and its \<^emph>\<open>input methods\<close>. Regular jEdit also provides various ways to
  work with \<^emph>\<open>abbreviations\<close> to produce certain non-ASCII characters. Since
  none of these standard input methods work satisfactorily for the
  mathematical characters required for Isabelle, various specific
  Isabelle/jEdit mechanisms are provided.

  This is a summary for practically relevant input methods for Isabelle
  symbols.

  \<^enum> The \<^emph>\<open>Symbols\<close> panel: some GUI buttons allow to insert certain symbols in
  the text buffer. There are also tooltips to reveal the official Isabelle
  representation with some additional information about \<^emph>\<open>symbol
  abbreviations\<close> (see below).

  \<^enum> Copy/paste from decoded source files: text that is rendered as Unicode
  already can be re-used to produce further text. This also works between
  different applications, e.g.\ Isabelle/jEdit and some web browser or mail
  client, as long as the same Unicode view on Isabelle symbols is used.

  \<^enum> Copy/paste from prover output within Isabelle/jEdit. The same principles
  as for text buffers apply, but note that \<^emph>\<open>copy\<close> in secondary Isabelle/jEdit
  windows works via the keyboard shortcuts \<^verbatim>\<open>C+c\<close> or \<^verbatim>\<open>C+INSERT\<close>, while jEdit
  menu actions always refer to the primary text area!

  \<^enum> Completion provided by Isabelle plugin (see \secref{sec:completion}).
  Isabelle symbols have a canonical name and optional abbreviations. This can
  be used with the text completion mechanism of Isabelle/jEdit, to replace a
  prefix of the actual symbol like \<^verbatim>\<open>\<lambda>\<close>, or its name preceded by backslash
  \<^verbatim>\<open>\lambda\<close>, or its ASCII abbreviation \<^verbatim>\<open>%\<close> by the Unicode rendering.

  The following table is an extract of the information provided by the
  standard @{file "$ISABELLE_HOME/etc/symbols"} file:

  \<^medskip>
  \begin{tabular}{lll}
    \<^bold>\<open>symbol\<close> & \<^bold>\<open>name with backslash\<close> & \<^bold>\<open>abbreviation\<close> \\\hline
    \<open>\<lambda>\<close> & \<^verbatim>\<open>\lambda\<close> & \<^verbatim>\<open>%\<close> \\
    \<open>\<Rightarrow>\<close> & \<^verbatim>\<open>\Rightarrow\<close> & \<^verbatim>\<open>=>\<close> \\
    \<open>\<Longrightarrow>\<close> & \<^verbatim>\<open>\Longrightarrow\<close> & \<^verbatim>\<open>==>\<close> \\[0.5ex]
    \<open>\<And>\<close> & \<^verbatim>\<open>\And\<close> & \<^verbatim>\<open>!!\<close> \\
    \<open>\<equiv>\<close> & \<^verbatim>\<open>\equiv\<close> & \<^verbatim>\<open>==\<close> \\[0.5ex]
    \<open>\<forall>\<close> & \<^verbatim>\<open>\forall\<close> & \<^verbatim>\<open>!\<close> \\
    \<open>\<exists>\<close> & \<^verbatim>\<open>\exists\<close> & \<^verbatim>\<open>?\<close> \\
    \<open>\<longrightarrow>\<close> & \<^verbatim>\<open>\longrightarrow\<close> & \<^verbatim>\<open>-->\<close> \\
    \<open>\<and>\<close> & \<^verbatim>\<open>\and\<close> & \<^verbatim>\<open>&\<close> \\
    \<open>\<or>\<close> & \<^verbatim>\<open>\or\<close> & \<^verbatim>\<open>|\<close> \\
    \<open>\<not>\<close> & \<^verbatim>\<open>\not\<close> & \<^verbatim>\<open>~\<close> \\
    \<open>\<noteq>\<close> & \<^verbatim>\<open>\noteq\<close> & \<^verbatim>\<open>~=\<close> \\
    \<open>\<in>\<close> & \<^verbatim>\<open>\in\<close> & \<^verbatim>\<open>:\<close> \\
    \<open>\<notin>\<close> & \<^verbatim>\<open>\notin\<close> & \<^verbatim>\<open>~:\<close> \\
  \end{tabular}
  \<^medskip>

  Note that the above abbreviations refer to the input method. The logical
  notation provides ASCII alternatives that often coincide, but sometimes
  deviate. This occasionally causes user confusion with very old-fashioned
  Isabelle source that use ASCII replacement notation like \<^verbatim>\<open>!\<close> or \<^verbatim>\<open>ALL\<close>
  directly in the text.

  On the other hand, coincidence of symbol abbreviations with ASCII
  replacement syntax syntax helps to update old theory sources via explicit
  completion (see also \<^verbatim>\<open>C+b\<close> explained in \secref{sec:completion}).
\<close>

paragraph \<open>Control symbols.\<close>
text \<open>There are some special control symbols to modify the display style of a
  single symbol (without nesting). Control symbols may be applied to a region
  of selected text, either using the \<^emph>\<open>Symbols\<close> panel or keyboard shortcuts or
  jEdit actions. These editor operations produce a separate control symbol for
  each symbol in the text, in order to make the whole text appear in a certain
  style.

  \<^medskip>
  \begin{tabular}{llll}
    \<^bold>\<open>style\<close> & \<^bold>\<open>symbol\<close> & \<^bold>\<open>shortcut\<close> & \<^bold>\<open>action\<close> \\\hline
    superscript & \<^verbatim>\<open>\<^sup>\<close> & \<^verbatim>\<open>C+e UP\<close> & @{action_ref "isabelle.control-sup"} \\
    subscript & \<^verbatim>\<open>\<^sub>\<close> & \<^verbatim>\<open>C+e DOWN\<close> & @{action_ref "isabelle.control-sub"} \\
    bold face & \<^verbatim>\<open>\<^bold>\<close> & \<^verbatim>\<open>C+e RIGHT\<close> & @{action_ref "isabelle.control-bold"} \\
    emphasized & \<^verbatim>\<open>\<^emph>\<close> & \<^verbatim>\<open>C+e LEFT\<close> & @{action_ref "isabelle.control-emph"} \\
    reset & & \<^verbatim>\<open>C+e BACK_SPACE\<close> & @{action_ref "isabelle.control-reset"} \\
  \end{tabular}
  \<^medskip>

  To produce a single control symbol, it is also possible to complete on
  \<^verbatim>\<open>\sup\<close>, \<^verbatim>\<open>\sub\<close>, \<^verbatim>\<open>\bold\<close>, \<^verbatim>\<open>\emph\<close> as for regular symbols.

  The emphasized style only takes effect in document output, not in the
  editor.
\<close>


section \<open>SideKick parsers \label{sec:sidekick}\<close>

text \<open>
  The \<^emph>\<open>SideKick\<close> plugin provides some general services to display buffer
  structure in a tree view.

  Isabelle/jEdit provides SideKick parsers for its main mode for theory files,
  as well as some minor modes for the \<^verbatim>\<open>NEWS\<close> file (see
  \figref{fig:sidekick}), session \<^verbatim>\<open>ROOT\<close> files, and system \<^verbatim>\<open>options\<close>.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.333]{sidekick}
  \end{center}
  \caption{The Isabelle NEWS file with SideKick tree view}
  \label{fig:sidekick}
  \end{figure}

  Moreover, the special SideKick parser \<^verbatim>\<open>isabelle-markup\<close> provides access to
  the full (uninterpreted) markup tree of the PIDE document model of the
  current buffer. This is occasionally useful for informative purposes, but
  the amount of displayed information might cause problems for large buffers,
  both for the human and the machine.
\<close>


section \<open>Scala console \label{sec:scala-console}\<close>

text \<open>
  The \<^emph>\<open>Console\<close> plugin manages various shells (command interpreters), e.g.\
  \<^emph>\<open>BeanShell\<close>, which is the official jEdit scripting language, and the
  cross-platform \<^emph>\<open>System\<close> shell. Thus the console provides similar
  functionality than the Emacs buffers \<^verbatim>\<open>*scratch*\<close> and \<^verbatim>\<open>*shell*\<close>.

  Isabelle/jEdit extends the repertoire of the console by \<^emph>\<open>Scala\<close>, which is
  the regular Scala toplevel loop running inside the same JVM process as
  Isabelle/jEdit itself. This means the Scala command interpreter has access
  to the JVM name space and state of the running Prover IDE application. The
  default environment imports the full content of packages \<^verbatim>\<open>isabelle\<close> and
  \<^verbatim>\<open>isabelle.jedit\<close>.

  For example, \<^verbatim>\<open>PIDE\<close> refers to the Isabelle/jEdit plugin object, and \<^verbatim>\<open>view\<close>
  to the current editor view of jEdit. The Scala expression
  \<^verbatim>\<open>PIDE.snapshot(view)\<close> makes a PIDE document snapshot of the current buffer
  within the current editor view.

  This helps to explore Isabelle/Scala functionality interactively. Some care
  is required to avoid interference with the internals of the running
  application, especially in production use.
\<close>


section \<open>File-system access\<close>

text \<open>
  File specifications in jEdit follow various formats and conventions
  according to \<^emph>\<open>Virtual File Systems\<close>, which may be also provided by
  additional plugins. This allows to access remote files via the \<^verbatim>\<open>http:\<close>
  protocol prefix, for example. Isabelle/jEdit attempts to work with the
  file-system model of jEdit as far as possible. In particular, theory sources
  are passed directly from the editor to the prover, without indirection via
  physical files.

  Despite the flexibility of URLs in jEdit, local files are particularly
  important and are accessible without protocol prefix. Here the path notation
  is that of the Java Virtual Machine on the underlying platform. On Windows
  the preferred form uses backslashes, but happens to accept also forward
  slashes like Unix/POSIX. Further differences arise due to Windows drive
  letters and network shares.

  The Java notation for files needs to be distinguished from the one of
  Isabelle, which uses POSIX notation with forward slashes on \<^emph>\<open>all\<close>
  platforms.\<^footnote>\<open>Isabelle/ML on Windows uses Cygwin file-system access and
  Unix-style path notation.\<close> Moreover, environment variables from the Isabelle
  process may be used freely, e.g.\ @{file "$ISABELLE_HOME/etc/symbols"} or
  @{file_unchecked "$POLYML_HOME/README"}. There are special shortcuts: @{file
  "~"} for @{file "$USER_HOME"} and @{file "~~"} for @{file "$ISABELLE_HOME"}.

  \<^medskip>
  Since jEdit happens to support environment variables within file
  specifications as well, it is natural to use similar notation within the
  editor, e.g.\ in the file-browser. This does not work in full generality,
  though, due to the bias of jEdit towards platform-specific notation and of
  Isabelle towards POSIX. Moreover, the Isabelle settings environment is not
  yet active when starting Isabelle/jEdit via its standard application
  wrapper, in contrast to @{tool jedit} run from the command line
  (\secref{sec:command-line}).

  Isabelle/jEdit imitates \<^verbatim>\<open>$ISABELLE_HOME\<close> and \<^verbatim>\<open>$ISABELLE_HOME_USER\<close> within
  the Java process environment, in order to allow easy access to these
  important places from the editor. The file browser of jEdit also includes
  \<^emph>\<open>Favorites\<close> for these two important locations.

  \<^medskip>
  Path specifications in prover input or output usually include formal markup
  that turns it into a hyperlink (see also \secref{sec:tooltips-hyperlinks}).
  This allows to open the corresponding file in the text editor, independently
  of the path notation.

  Formally checked paths in prover input are subject to completion
  (\secref{sec:completion}): partial specifications are resolved via directory
  content and possible completions are offered in a popup.
\<close>


chapter \<open>Prover IDE functionality \label{sec:document-model}\<close>

section \<open>Document model \label{sec:document-model}\<close>

text \<open>
  The document model is central to the PIDE architecture: the editor and the
  prover have a common notion of structured source text with markup, which is
  produced by formal processing. The editor is responsible for edits of
  document source, as produced by the user. The prover is responsible for
  reports of document markup, as produced by its processing in the background.

  Isabelle/jEdit handles classic editor events of jEdit, in order to connect
  the physical world of the GUI (with its singleton state) to the mathematical
  world of multiple document versions (with timeless and stateless updates).
\<close>


subsection \<open>Editor buffers and document nodes \label{sec:buffer-node}\<close>

text \<open>
  As a regular text editor, jEdit maintains a collection of \<^emph>\<open>buffers\<close> to
  store text files; each buffer may be associated with any number of visible
  \<^emph>\<open>text areas\<close>. Buffers are subject to an \<^emph>\<open>edit mode\<close> that is determined
  from the file name extension. The following modes are treated specifically
  in Isabelle/jEdit:

  \<^medskip>
  \begin{tabular}{lll}
  \<^bold>\<open>mode\<close> & \<^bold>\<open>file extension\<close> & \<^bold>\<open>content\<close> \\\hline
  \<^verbatim>\<open>isabelle\<close> & \<^verbatim>\<open>.thy\<close> & theory source \\
  \<^verbatim>\<open>isabelle-ml\<close> & \<^verbatim>\<open>.ML\<close> & Isabelle/ML source \\
  \<^verbatim>\<open>sml\<close> & \<^verbatim>\<open>.sml\<close> or \<^verbatim>\<open>.sig\<close> & Standard ML source \\
  \end{tabular}
  \<^medskip>

  All jEdit buffers are automatically added to the PIDE document-model as
  \<^emph>\<open>document nodes\<close>. The overall document structure is defined by the theory
  nodes in two dimensions:

    \<^enum> via \<^bold>\<open>theory imports\<close> that are specified in the \<^emph>\<open>theory header\<close> using
    concrete syntax of the @{command_ref theory} command @{cite
    "isabelle-isar-ref"};

    \<^enum> via \<^bold>\<open>auxiliary files\<close> that are loaded into a theory by special \<^emph>\<open>load
    commands\<close>, notably @{command_ref ML_file} and @{command_ref SML_file}
    @{cite "isabelle-isar-ref"}.

  In any case, source files are managed by the PIDE infrastructure: the
  physical file-system only plays a subordinate role. The relevant version of
  source text is passed directly from the editor to the prover, using internal
  communication channels.
\<close>


subsection \<open>Theories \label{sec:theories}\<close>

text \<open>
  The \<^emph>\<open>Theories\<close> panel (see also \figref{fig:theories}) provides an overview
  of the status of continuous checking of theory nodes within the document
  model. Unlike batch sessions of @{tool build} @{cite "isabelle-system"},
  theory nodes are identified by full path names; this allows to work with
  multiple (disjoint) Isabelle sessions simultaneously within the same editor
  session.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.333]{theories}
  \end{center}
  \caption{Theories panel with an overview of the document-model, and some
  jEdit text areas as editable view on some of the document nodes}
  \label{fig:theories}
  \end{figure}

  Certain events to open or update editor buffers cause Isabelle/jEdit to
  resolve dependencies of theory imports. The system requests to load
  additional files into editor buffers, in order to be included in the
  document model for further checking. It is also possible to let the system
  resolve dependencies automatically, according to the system option
  @{system_option jedit_auto_load}.

  \<^medskip>
  The visible \<^emph>\<open>perspective\<close> of Isabelle/jEdit is defined by the collective
  view on theory buffers via open text areas. The perspective is taken as a
  hint for document processing: the prover ensures that those parts of a
  theory where the user is looking are checked, while other parts that are
  presently not required are ignored. The perspective is changed by opening or
  closing text area windows, or scrolling within a window.

  The \<^emph>\<open>Theories\<close> panel provides some further options to influence the process
  of continuous checking: it may be switched off globally to restrict the
  prover to superficial processing of command syntax. It is also possible to
  indicate theory nodes as \<^emph>\<open>required\<close> for continuous checking: this means
  such nodes and all their imports are always processed independently of the
  visibility status (if continuous checking is enabled). Big theory libraries
  that are marked as required can have significant impact on performance,
  though.

  \<^medskip>
  Formal markup of checked theory content is turned into GUI rendering, based
  on a standard repertoire known from IDEs for programming languages: colors,
  icons, highlighting, squiggly underlines, tooltips, hyperlinks etc. For
  outer syntax of Isabelle/Isar there is some traditional syntax-highlighting
  via static keywords and tokenization within the editor; this buffer syntax
  is determined from theory imports. In contrast, the painting of inner syntax
  (term language etc.)\ uses semantic information that is reported dynamically
  from the logical context. Thus the prover can provide additional markup to
  help the user to understand the meaning of formal text, and to produce more
  text with some add-on tools (e.g.\ information messages with \<^emph>\<open>sendback\<close>
  markup by automated provers or disprovers in the background).
\<close>


subsection \<open>Auxiliary files \label{sec:aux-files}\<close>

text \<open>
  Special load commands like @{command_ref ML_file} and @{command_ref
  SML_file} @{cite "isabelle-isar-ref"} refer to auxiliary files within some
  theory. Conceptually, the file argument of the command extends the theory
  source by the content of the file, but its editor buffer may be loaded~/
  changed~/ saved separately. The PIDE document model propagates changes of
  auxiliary file content to the corresponding load command in the theory, to
  update and process it accordingly: changes of auxiliary file content are
  treated as changes of the corresponding load command.

  \<^medskip>
  As a concession to the massive amount of ML files in Isabelle/HOL itself,
  the content of auxiliary files is only added to the PIDE document-model on
  demand, the first time when opened explicitly in the editor. There are
  further tricks to manage markup of ML files, such that Isabelle/HOL may be
  edited conveniently in the Prover IDE on small machines with only 8\,GB of
  main memory. Using \<^verbatim>\<open>Pure\<close> as logic session image, the exploration may start
  at the top @{file "$ISABELLE_HOME/src/HOL/Main.thy"} or the bottom @{file
  "$ISABELLE_HOME/src/HOL/HOL.thy"}, for example.

  Initially, before an auxiliary file is opened in the editor, the prover
  reads its content from the physical file-system. After the file is opened
  for the first time in the editor, e.g.\ by following the hyperlink
  (\secref{sec:tooltips-hyperlinks}) for the argument of its @{command
  ML_file} command, the content is taken from the jEdit buffer.

  The change of responsibility from prover to editor counts as an update of
  the document content, so subsequent theory sources need to be re-checked.
  When the buffer is closed, the responsibility remains to the editor: the
  file may be opened again without causing another document update.

  A file that is opened in the editor, but its theory with the load command is
  not, is presently inactive in the document model. A file that is loaded via
  multiple load commands is associated to an arbitrary one: this situation is
  morally unsupported and might lead to confusion.

  \<^medskip>
  Output that refers to an auxiliary file is combined with that of the
  corresponding load command, and shown whenever the file or the command are
  active (see also \secref{sec:output}).

  Warnings, errors, and other useful markup is attached directly to the
  positions in the auxiliary file buffer, in the manner of other well-known
  IDEs. By using the load command @{command SML_file} as explained in @{file
  "$ISABELLE_HOME/src/Tools/SML/Examples.thy"}, Isabelle/jEdit may be used as
  fully-featured IDE for Standard ML, independently of theory or proof
  development: the required theory merely serves as some kind of project file
  for a collection of SML source modules.
\<close>


section \<open>Output \label{sec:output}\<close>

text \<open>
  Prover output consists of \<^emph>\<open>markup\<close> and \<^emph>\<open>messages\<close>. Both are directly
  attached to the corresponding positions in the original source text, and
  visualized in the text area, e.g.\ as text colours for free and bound
  variables, or as squiggly underlines for warnings, errors etc.\ (see also
  \figref{fig:output}). In the latter case, the corresponding messages are
  shown by hovering with the mouse over the highlighted text --- although in
  many situations the user should already get some clue by looking at the
  position of the text highlighting, without the text itself.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.333]{output}
  \end{center}
  \caption{Multiple views on prover output: gutter area with icon,
    text area with popup, overview area, Theories panel, Output panel}
  \label{fig:output}
  \end{figure}

  The ``gutter area'' on the left-hand-side of the text area uses icons to
  provide a summary of the messages within the adjacent line of text. Message
  priorities are used to prefer errors over warnings, warnings over
  information messages, but plain output is ignored.

  The ``overview area'' on the right-hand-side of the text area uses similar
  information to paint small rectangles for the overall status of the whole
  text buffer. The graphics is scaled to fit the logical buffer length into
  the given window height. Mouse clicks on the overview area position the
  cursor approximately to the corresponding line of text in the buffer.

  Another course-grained overview is provided by the \<^emph>\<open>Theories\<close> panel, but
  without direct correspondence to text positions. A double-click on one of
  the theory entries with their status overview opens the corresponding text
  buffer, without changing the cursor position.

  \<^medskip>
  In addition, the \<^emph>\<open>Output\<close> panel displays prover messages that correspond to
  a given command, within a separate window.

  The cursor position in the presently active text area determines the prover
  command whose cumulative message output is appended and shown in that window
  (in canonical order according to the internal execution of the command).
  There are also control elements to modify the update policy of the output
  wrt.\ continued editor movements. This is particularly useful with several
  independent instances of the \<^emph>\<open>Output\<close> panel, which the Dockable Window
  Manager of jEdit can handle conveniently.

  Former users of the old TTY interaction model (e.g.\ Proof~General) might
  find a separate window for prover messages familiar, but it is important to
  understand that the main Prover IDE feedback happens elsewhere. It is
  possible to do meaningful proof editing within the primary text area and its
  markup, while using secondary output windows only rarely.

  The main purpose of the output window is to ``debug'' unclear situations by
  inspecting internal state of the prover.\<^footnote>\<open>In that sense, unstructured tactic
  scripts depend on continuous debugging with internal state inspection.\<close>
  Consequently, some special messages for \<^emph>\<open>tracing\<close> or \<^emph>\<open>proof state\<close> only
  appear here, and are not attached to the original source.

  \<^medskip>
  In any case, prover messages also contain markup that may be explored
  recursively via tooltips or hyperlinks (see
  \secref{sec:tooltips-hyperlinks}), or clicked directly to initiate certain
  actions (see \secref{sec:auto-tools} and \secref{sec:sledgehammer}).
\<close>


section \<open>Query \label{sec:query}\<close>

text \<open>
  The \<^emph>\<open>Query\<close> panel provides various GUI forms to request extra information
  from the prover. In old times the user would have issued some diagnostic
  command like @{command find_theorems} and inspected its output, but this is
  now integrated into the Prover IDE.

  A \<^emph>\<open>Query\<close> window provides some input fields and buttons for a particular
  query command, with output in a dedicated text area. There are various query
  modes: \<^emph>\<open>Find Theorems\<close>, \<^emph>\<open>Find Constants\<close>, \<^emph>\<open>Print Context\<close>, e.g.\ see
  \figref{fig:query}. As usual in jEdit, multiple \<^emph>\<open>Query\<close> windows may be
  active at the same time: any number of floating instances, but at most one
  docked instance (which is used by default).

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.333]{query}
  \end{center}
  \caption{An instance of the Query panel}
  \label{fig:query}
  \end{figure}

  \<^medskip>
  The following GUI elements are common to all query modes:

    \<^item> The spinning wheel provides feedback about the status of a pending query
    wrt.\ the evaluation of its context and its own operation.

    \<^item> The \<^emph>\<open>Apply\<close> button attaches a fresh query invocation to the current
    context of the command where the cursor is pointing in the text.

    \<^item> The \<^emph>\<open>Search\<close> field allows to highlight query output according to some
    regular expression, in the notation that is commonly used on the Java
    platform.\<^footnote>\<open>@{url
    "https://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html"}\<close>
    This may serve as an additional visual filter of the result.

    \<^item> The \<^emph>\<open>Zoom\<close> box controls the font size of the output area.

  All query operations are asynchronous: there is no need to wait for the
  evaluation of the document for the query context, nor for the query
  operation itself. Query output may be detached as independent \<^emph>\<open>Info\<close>
  window, using a menu operation of the dockable window manager. The printed
  result usually provides sufficient clues about the original query, with some
  hyperlink to its context (via markup of its head line).
\<close>


subsection \<open>Find theorems\<close>

text \<open>
  The \<^emph>\<open>Query\<close> panel in \<^emph>\<open>Find Theorems\<close> mode retrieves facts from the theory
  or proof context matching all of given criteria in the \<^emph>\<open>Find\<close> text field. A
  single criterium has the following syntax:

  @{rail \<open>
    ('-'?) ('name' ':' @{syntax nameref} | 'intro' | 'elim' | 'dest' |
      'solves' | 'simp' ':' @{syntax term} | @{syntax term})
  \<close>}

  See also the Isar command @{command_ref find_theorems} in @{cite
  "isabelle-isar-ref"}.
\<close>


subsection \<open>Find constants\<close>

text \<open>
  The \<^emph>\<open>Query\<close> panel in \<^emph>\<open>Find Constants\<close> mode prints all constants whose type
  meets all of the given criteria in the \<^emph>\<open>Find\<close> text field. A single
  criterium has the following syntax:

  @{rail \<open>
    ('-'?)
      ('name' ':' @{syntax nameref} | 'strict' ':' @{syntax type} | @{syntax type})
  \<close>}

  See also the Isar command @{command_ref find_consts} in @{cite
  "isabelle-isar-ref"}.
\<close>


subsection \<open>Print context\<close>

text \<open>
  The \<^emph>\<open>Query\<close> panel in \<^emph>\<open>Print Context\<close> mode prints information from the
  theory or proof context, or proof state. See also the Isar commands
  @{command_ref print_context}, @{command_ref print_cases}, @{command_ref
  print_term_bindings}, @{command_ref print_theorems}, @{command_ref
  print_state} described in @{cite "isabelle-isar-ref"}.
\<close>


section \<open>Tooltips and hyperlinks \label{sec:tooltips-hyperlinks}\<close>

text \<open>
  Formally processed text (prover input or output) contains rich markup
  information that can be explored further by using the \<^verbatim>\<open>CONTROL\<close> modifier
  key on Linux and Windows, or \<^verbatim>\<open>COMMAND\<close> on Mac OS X. Hovering with the mouse
  while the modifier is pressed reveals a \<^emph>\<open>tooltip\<close> (grey box over the text
  with a yellow popup) and/or a \<^emph>\<open>hyperlink\<close> (black rectangle over the text
  with change of mouse pointer); see also \figref{fig:tooltip}.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.5]{popup1}
  \end{center}
  \caption{Tooltip and hyperlink for some formal entity}
  \label{fig:tooltip}
  \end{figure}

  Tooltip popups use the same rendering mechanisms as the main text area, and
  further tooltips and/or hyperlinks may be exposed recursively by the same
  mechanism; see \figref{fig:nested-tooltips}.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.5]{popup2}
  \end{center}
  \caption{Nested tooltips over formal entities}
  \label{fig:nested-tooltips}
  \end{figure}

  The tooltip popup window provides some controls to \<^emph>\<open>close\<close> or \<^emph>\<open>detach\<close> the
  window, turning it into a separate \<^emph>\<open>Info\<close> window managed by jEdit. The
  \<^verbatim>\<open>ESCAPE\<close> key closes \<^emph>\<open>all\<close> popups, which is particularly relevant when
  nested tooltips are stacking up.

  \<^medskip>
  A black rectangle in the text indicates a hyperlink that may be followed by
  a mouse click (while the \<^verbatim>\<open>CONTROL\<close> or \<^verbatim>\<open>COMMAND\<close> modifier key is still
  pressed). Such jumps to other text locations are recorded by the
  \<^emph>\<open>Navigator\<close> plugin, which is bundled with Isabelle/jEdit and enabled by
  default, including navigation arrows in the main jEdit toolbar.

  Also note that the link target may be a file that is itself not subject to
  formal document processing of the editor session and thus prevents further
  exploration: the chain of hyperlinks may end in some source file of the
  underlying logic image, or within the ML bootstrap sources of
  Isabelle/Pure.
\<close>


section \<open>Completion \label{sec:completion}\<close>

text \<open>
  Smart completion of partial input is the IDE functionality \<^emph>\<open>par
  excellance\<close>. Isabelle/jEdit combines several sources of information to
  achieve that. Despite its complexity, it should be possible to get some idea
  how completion works by experimentation, based on the overview of completion
  varieties in \secref{sec:completion-varieties}. The remaining subsections
  explain concepts around completion more systematically.

  \<^medskip>
  \<^emph>\<open>Explicit completion\<close> is triggered by the action @{action_ref
  "isabelle.complete"}, which is bound to the keyboard shortcut \<^verbatim>\<open>C+b\<close>, and
  thus overrides the jEdit default for @{action_ref "complete-word"}.

  \<^emph>\<open>Implicit completion\<close> hooks into the regular keyboard input stream of the
  editor, with some event filtering and optional delays.

  \<^medskip>
  Completion options may be configured in \<^emph>\<open>Plugin Options~/ Isabelle~/
  General~/ Completion\<close>. These are explained in further detail below, whenever
  relevant. There is also a summary of options in
  \secref{sec:completion-options}.

  The asynchronous nature of PIDE interaction means that information from the
  prover is delayed --- at least by a full round-trip of the document update
  protocol. The default options already take this into account, with a
  sufficiently long completion delay to speculate on the availability of all
  relevant information from the editor and the prover, before completing text
  immediately or producing a popup. Although there is an inherent danger of
  non-deterministic behaviour due to such real-time parameters, the general
  completion policy aims at determined results as far as possible.
\<close>


subsection \<open>Varieties of completion \label{sec:completion-varieties}\<close>

subsubsection \<open>Built-in templates\<close>

text \<open>
  Isabelle is ultimately a framework of nested sub-languages of different
  kinds and purposes. The completion mechanism supports this by the following
  built-in templates:

    \<^descr> \<^verbatim>\<open>`\<close> (single ASCII back-quote) supports \<^emph>\<open>quotations\<close> via text
    cartouches. There are three selections, which are always presented in the
    same order and do not depend on any context information. The default
    choice produces a template ``\<open>\<open>\<box>\<close>\<close>'', where the box indicates the cursor
    position after insertion; the other choices help to repair the block
    structure of unbalanced text cartouches.

    \<^descr> \<^verbatim>\<open>@{\<close> is completed to the template ``\<open>@{\<box>}\<close>'', where the box indicates
    the cursor position after insertion. Here it is convenient to use the
    wildcard ``\<^verbatim>\<open>__\<close>'' or a more specific name prefix to let semantic
    completion of name-space entries propose antiquotation names.

  With some practice, input of quoted sub-languages and antiquotations of
  embedded languages should work fluently. Note that national keyboard layouts
  might cause problems with back-quote as dead key: if possible, dead keys
  should be disabled.
\<close>


subsubsection \<open>Syntax keywords\<close>

text \<open>
  Syntax completion tables are determined statically from the keywords of the
  ``outer syntax'' of the underlying edit mode: for theory files this is the
  syntax of Isar commands according to the cumulative theory imports.

  Keywords are usually plain words, which means the completion mechanism only
  inserts them directly into the text for explicit completion
  (\secref{sec:completion-input}), but produces a popup
  (\secref{sec:completion-popup}) otherwise.

  At the point where outer syntax keywords are defined, it is possible to
  specify an alternative replacement string to be inserted instead of the
  keyword itself. An empty string means to suppress the keyword altogether,
  which is occasionally useful to avoid confusion, e.g.\ the rare keyword
  @{command simproc_setup} vs.\ the frequent name-space entry \<open>simp\<close>.
\<close>


subsubsection \<open>Isabelle symbols\<close>

text \<open>
  The completion tables for Isabelle symbols (\secref{sec:symbols}) are
  determined statically from @{file "$ISABELLE_HOME/etc/symbols"} and
  @{file_unchecked "$ISABELLE_HOME_USER/etc/symbols"} for each symbol
  specification as follows:

  \<^medskip>
  \begin{tabular}{ll}
  \<^bold>\<open>completion entry\<close> & \<^bold>\<open>example\<close> \\\hline
  literal symbol & \<^verbatim>\<open>\<forall>\<close> \\
  symbol name with backslash & \<^verbatim>\<open>\\<close>\<^verbatim>\<open>forall\<close> \\
  symbol abbreviation & \<^verbatim>\<open>ALL\<close> or \<^verbatim>\<open>!\<close> \\
  \end{tabular}
  \<^medskip>

  When inserted into the text, the above examples all produce the same Unicode
  rendering \<open>\<forall>\<close> of the underlying symbol \<^verbatim>\<open>\<forall>\<close>.

  A symbol abbreviation that is a plain word, like \<^verbatim>\<open>ALL\<close>, is treated like a
  syntax keyword. Non-word abbreviations like \<^verbatim>\<open>-->\<close> are inserted more
  aggressively, except for single-character abbreviations like \<^verbatim>\<open>!\<close> above.

  \<^medskip>
  Additional abbreviations may be specified in @{file
  "$ISABELLE_HOME/etc/abbrevs"} and @{file_unchecked
  "$ISABELLE_HOME_USER/etc/abbrevs"}. The file content follows general Isar
  outer syntax @{cite "isabelle-isar-ref"}. Abbreviations are specified as
  ``\<open>abbrev\<close>~\<^verbatim>\<open>=\<close>~\<open>text\<close>'' pairs. The replacement \<open>text\<close> may consist of more
  than just one symbol; otherwise the meaning is the same as a symbol
  specification ``\<open>sym\<close>~\<^verbatim>\<open>abbrev:\<close>~\<open>abbrev\<close>'' within @{file_unchecked
  "etc/symbols"}.

  \<^medskip>
  Symbol completion depends on the semantic language context
  (\secref{sec:completion-context}), to enable or disable that aspect for a
  particular sub-language of Isabelle. For example, symbol completion is
  suppressed within document source to avoid confusion with {\LaTeX} macros
  that use similar notation.
\<close>


subsubsection \<open>Name-space entries\<close>

text \<open>
  This is genuine semantic completion, using information from the prover, so
  it requires some delay. A \<^emph>\<open>failed name-space lookup\<close> produces an error
  message that is annotated with a list of alternative names that are legal.
  The list of results is truncated according to the system option
  @{system_option_ref completion_limit}. The completion mechanism takes this
  into account when collecting information on the prover side.

  Already recognized names are \<^emph>\<open>not\<close> completed further, but completion may be
  extended by appending a suffix of underscores. This provokes a failed
  lookup, and another completion attempt while ignoring the underscores. For
  example, in a name space where \<^verbatim>\<open>foo\<close> and \<^verbatim>\<open>foobar\<close> are known, the input
  \<^verbatim>\<open>foo\<close> remains unchanged, but \<^verbatim>\<open>foo_\<close> may be completed to \<^verbatim>\<open>foo\<close> or
  \<^verbatim>\<open>foobar\<close>.

  The special identifier ``\<^verbatim>\<open>__\<close>'' serves as a wild-card for arbitrary
  completion: it exposes the name-space content to the completion mechanism
  (truncated according to @{system_option completion_limit}). This is
  occasionally useful to explore an unknown name-space, e.g.\ in some
  template.
\<close>


subsubsection \<open>File-system paths\<close>

text \<open>
  Depending on prover markup about file-system path specifications in the
  source text, e.g.\ for the argument of a load command
  (\secref{sec:aux-files}), the completion mechanism explores the directory
  content and offers the result as completion popup. Relative path
  specifications are understood wrt.\ the \<^emph>\<open>master directory\<close> of the document
  node (\secref{sec:buffer-node}) of the enclosing editor buffer; this
  requires a proper theory, not an auxiliary file.

  A suffix of slashes may be used to continue the exploration of an already
  recognized directory name.
\<close>


subsubsection \<open>Spell-checking\<close>

text \<open>
  The spell-checker combines semantic markup from the prover (regions of plain
  words) with static dictionaries (word lists) that are known to the editor.

  Unknown words are underlined in the text, using @{system_option_ref
  spell_checker_color} (blue by default). This is not an error, but a hint to
  the user that some action may be taken. The jEdit context menu provides
  various actions, as far as applicable:

  \<^medskip>
  \begin{tabular}{l}
  @{action_ref "isabelle.complete-word"} \\
  @{action_ref "isabelle.exclude-word"} \\
  @{action_ref "isabelle.exclude-word-permanently"} \\
  @{action_ref "isabelle.include-word"} \\
  @{action_ref "isabelle.include-word-permanently"} \\
  \end{tabular}
  \<^medskip>

  Instead of the specific @{action_ref "isabelle.complete-word"}, it is also
  possible to use the generic @{action_ref "isabelle.complete"} with its
  default keyboard shortcut \<^verbatim>\<open>C+b\<close>.

  \<^medskip>
  Dictionary lookup uses some educated guesses about lower-case, upper-case,
  and capitalized words. This is oriented on common use in English, where this
  aspect is not decisive for proper spelling, in contrast to German, for
  example.
\<close>


subsection \<open>Semantic completion context \label{sec:completion-context}\<close>

text \<open>
  Completion depends on a semantic context that is provided by the prover,
  although with some delay, because at least a full PIDE protocol round-trip
  is required. Until that information becomes available in the PIDE
  document-model, the default context is given by the outer syntax of the
  editor mode (see also \secref{sec:buffer-node}).

  The semantic \<^emph>\<open>language context\<close> provides information about nested
  sub-languages of Isabelle: keywords are only completed for outer syntax,
  symbols or antiquotations for languages that support them. E.g.\ there is no
  symbol completion for ML source, but within ML strings, comments,
  antiquotations.

  The prover may produce \<^emph>\<open>no completion\<close> markup in exceptional situations, to
  tell that some language keywords should be excluded from further completion
  attempts. For example, \<^verbatim>\<open>:\<close> within accepted Isar syntax looses its meaning
  as abbreviation for symbol \<open>\<in>\<close>.

  \<^medskip>
  The completion context is \<^emph>\<open>ignored\<close> for built-in templates and symbols in
  their explicit form ``\<^verbatim>\<open>\<foobar>\<close>''; see also
  \secref{sec:completion-varieties}. This allows to complete within broken
  input that escapes its normal semantic context, e.g.\ antiquotations or
  string literals in ML, which do not allow arbitrary backslash sequences.
\<close>


subsection \<open>Input events \label{sec:completion-input}\<close>

text \<open>
  Completion is triggered by certain events produced by the user, with
  optional delay after keyboard input according to @{system_option
  jedit_completion_delay}.

  \<^descr>[Explicit completion] works via action @{action_ref "isabelle.complete"}
  with keyboard shortcut \<^verbatim>\<open>C+b\<close>. This overrides the shortcut for @{action_ref
  "complete-word"} in jEdit, but it is possible to restore the original jEdit
  keyboard mapping of @{action "complete-word"} via \<^emph>\<open>Global Options~/
  Shortcuts\<close> and invent a different one for @{action "isabelle.complete"}.

  \<^descr>[Explicit spell-checker completion] works via @{action_ref
  "isabelle.complete-word"}, which is exposed in the jEdit context menu, if
  the mouse points to a word that the spell-checker can complete.

  \<^descr>[Implicit completion] works via regular keyboard input of the editor. It
  depends on further side-conditions:

    \<^enum> The system option @{system_option_ref jedit_completion} needs to be
    enabled (default).

    \<^enum> Completion of syntax keywords requires at least 3 relevant characters in
    the text.

    \<^enum> The system option @{system_option_ref jedit_completion_delay} determines
    an additional delay (0.5 by default), before opening a completion popup.
    The delay gives the prover a chance to provide semantic completion
    information, notably the context (\secref{sec:completion-context}).

    \<^enum> The system option @{system_option_ref jedit_completion_immediate}
    (enabled by default) controls whether replacement text should be inserted
    immediately without popup, regardless of @{system_option
    jedit_completion_delay}. This aggressive mode of completion is restricted
    to Isabelle symbols and their abbreviations (\secref{sec:symbols}).

    \<^enum> Completion of symbol abbreviations with only one relevant character in
    the text always enforces an explicit popup, regardless of
    @{system_option_ref jedit_completion_immediate}.
\<close>


subsection \<open>Completion popup \label{sec:completion-popup}\<close>

text \<open>
  A \<^emph>\<open>completion popup\<close> is a minimally invasive GUI component over the text
  area that offers a selection of completion items to be inserted into the
  text, e.g.\ by mouse clicks. Items are sorted dynamically, according to the
  frequency of selection, with persistent history. The popup may interpret
  special keys \<^verbatim>\<open>ENTER\<close>, \<^verbatim>\<open>TAB\<close>, \<^verbatim>\<open>ESCAPE\<close>, \<^verbatim>\<open>UP\<close>, \<^verbatim>\<open>DOWN\<close>, \<^verbatim>\<open>PAGE_UP\<close>,
  \<^verbatim>\<open>PAGE_DOWN\<close>, but all other key events are passed to the underlying text
  area. This allows to ignore unwanted completions most of the time and
  continue typing quickly. Thus the popup serves as a mechanism of
  confirmation of proposed items, but the default is to continue without
  completion.

  The meaning of special keys is as follows:

  \<^medskip>
  \begin{tabular}{ll}
  \<^bold>\<open>key\<close> & \<^bold>\<open>action\<close> \\\hline
  \<^verbatim>\<open>ENTER\<close> & select completion (if @{system_option jedit_completion_select_enter}) \\
  \<^verbatim>\<open>TAB\<close> & select completion (if @{system_option jedit_completion_select_tab}) \\
  \<^verbatim>\<open>ESCAPE\<close> & dismiss popup \\
  \<^verbatim>\<open>UP\<close> & move up one item \\
  \<^verbatim>\<open>DOWN\<close> & move down one item \\
  \<^verbatim>\<open>PAGE_UP\<close> & move up one page of items \\
  \<^verbatim>\<open>PAGE_DOWN\<close> & move down one page of items \\
  \end{tabular}
  \<^medskip>

  Movement within the popup is only active for multiple items. Otherwise the
  corresponding key event retains its standard meaning within the underlying
  text area.
\<close>


subsection \<open>Insertion \label{sec:completion-insert}\<close>

text \<open>
  Completion may first propose replacements to be selected (via a popup), or
  replace text immediately in certain situations and depending on certain
  options like @{system_option jedit_completion_immediate}. In any case,
  insertion works uniformly, by imitating normal jEdit text insertion,
  depending on the state of the \<^emph>\<open>text selection\<close>. Isabelle/jEdit tries to
  accommodate the most common forms of advanced selections in jEdit, but not
  all combinations make sense. At least the following important cases are
  well-defined:

    \<^descr>[No selection.] The original is removed and the replacement inserted,
    depending on the caret position.

    \<^descr>[Rectangular selection of zero width.] This special case is treated by
    jEdit as ``tall caret'' and insertion of completion imitates its normal
    behaviour: separate copies of the replacement are inserted for each line
    of the selection.

    \<^descr>[Other rectangular selection or multiple selections.] Here the original
    is removed and the replacement is inserted for each line (or segment) of
    the selection.

  Support for multiple selections is particularly useful for \<^emph>\<open>HyperSearch\<close>:
  clicking on one of the items in the \<^emph>\<open>HyperSearch Results\<close> window makes
  jEdit select all its occurrences in the corresponding line of text. Then
  explicit completion can be invoked via \<^verbatim>\<open>C+b\<close>, e.g.\ to replace occurrences
  of \<^verbatim>\<open>-->\<close> by \<open>\<longrightarrow>\<close>.

  \<^medskip>
  Insertion works by removing and inserting pieces of text from the buffer.
  This counts as one atomic operation on the jEdit history. Thus unintended
  completions may be reverted by the regular @{action undo} action of jEdit.
  According to normal jEdit policies, the recovered text after @{action undo}
  is selected: \<^verbatim>\<open>ESCAPE\<close> is required to reset the selection and to continue
  typing more text.
\<close>


subsection \<open>Options \label{sec:completion-options}\<close>

text \<open>
  This is a summary of Isabelle/Scala system options that are relevant for
  completion. They may be configured in \<^emph>\<open>Plugin Options~/ Isabelle~/ General\<close>
  as usual.

  \<^item> @{system_option_def completion_limit} specifies the maximum number of
  items for various semantic completion operations (name-space entries etc.)

  \<^item> @{system_option_def jedit_completion} guards implicit completion via
  regular jEdit key events (\secref{sec:completion-input}): it allows to
  disable implicit completion altogether.

  \<^item> @{system_option_def jedit_completion_select_enter} and @{system_option_def
  jedit_completion_select_tab} enable keys to select a completion item from
  the popup (\secref{sec:completion-popup}). Note that a regular mouse click
  on the list of items is always possible.

  \<^item> @{system_option_def jedit_completion_context} specifies whether the
  language context provided by the prover should be used at all. Disabling
  that option makes completion less ``semantic''. Note that incomplete or
  severely broken input may cause some disagreement of the prover and the user
  about the intended language context.

  \<^item> @{system_option_def jedit_completion_delay} and @{system_option_def
  jedit_completion_immediate} determine the handling of keyboard events for
  implicit completion (\secref{sec:completion-input}).

  A @{system_option jedit_completion_delay}~\<^verbatim>\<open>> 0\<close> postpones the processing of
  key events, until after the user has stopped typing for the given time span,
  but @{system_option jedit_completion_immediate}~\<^verbatim>\<open>"= true\<close> means that
  abbreviations of Isabelle symbols are handled nonetheless.

  \<^item> @{system_option_def jedit_completion_path_ignore} specifies ``glob''
  patterns to ignore in file-system path completion (separated by colons),
  e.g.\ backup files ending with tilde.

  \<^item> @{system_option_def spell_checker} is a global guard for all spell-checker
  operations: it allows to disable that mechanism altogether.

  \<^item> @{system_option_def spell_checker_dictionary} determines the current
  dictionary, taken from the colon-separated list in the settings variable
  @{setting_def JORTHO_DICTIONARIES}. There are jEdit actions to specify local
  updates to a dictionary, by including or excluding words. The result of
  permanent dictionary updates is stored in the directory @{file_unchecked
  "$ISABELLE_HOME_USER/dictionaries"}, in a separate file for each dictionary.

  \<^item> @{system_option_def spell_checker_elements} specifies a comma-separated
  list of markup elements that delimit words in the source that is subject to
  spell-checking, including various forms of comments.
\<close>


section \<open>Automatically tried tools \label{sec:auto-tools}\<close>

text \<open>
  Continuous document processing works asynchronously in the background.
  Visible document source that has been evaluated may get augmented by
  additional results of \<^emph>\<open>asynchronous print functions\<close>. The canonical example
  is proof state output, which is always enabled. More heavy-weight print
  functions may be applied, in order to prove or disprove parts of the formal
  text by other means.

  Isabelle/HOL provides various automatically tried tools that operate on
  outermost goal statements (e.g.\ @{command lemma}, @{command theorem}),
  independently of the state of the current proof attempt. They work
  implicitly without any arguments. Results are output as \<^emph>\<open>information
  messages\<close>, which are indicated in the text area by blue squiggles and a blue
  information sign in the gutter (see \figref{fig:auto-tools}). The message
  content may be shown as for other output (see also \secref{sec:output}).
  Some tools produce output with \<^emph>\<open>sendback\<close> markup, which means that clicking
  on certain parts of the output inserts that text into the source in the
  proper place.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.333]{auto-tools}
  \end{center}
  \caption{Result of automatically tried tools}
  \label{fig:auto-tools}
  \end{figure}

  \<^medskip>
  The following Isabelle system options control the behavior of automatically
  tried tools (see also the jEdit dialog window \<^emph>\<open>Plugin Options~/ Isabelle~/
  General~/ Automatically tried tools\<close>):

  \<^item> @{system_option_ref auto_methods} controls automatic use of a combination
  of standard proof methods (@{method auto}, @{method simp}, @{method blast},
  etc.). This corresponds to the Isar command @{command_ref "try0"} @{cite
  "isabelle-isar-ref"}.

  The tool is disabled by default, since unparameterized invocation of
  standard proof methods often consumes substantial CPU resources without
  leading to success.

  \<^item> @{system_option_ref auto_nitpick} controls a slightly reduced version of
  @{command_ref nitpick}, which tests for counterexamples using first-order
  relational logic. See also the Nitpick manual @{cite "isabelle-nitpick"}.

  This tool is disabled by default, due to the extra overhead of invoking an
  external Java process for each attempt to disprove a subgoal.

  \<^item> @{system_option_ref auto_quickcheck} controls automatic use of
  @{command_ref quickcheck}, which tests for counterexamples using a series of
  assignments for free variables of a subgoal.

  This tool is \<^emph>\<open>enabled\<close> by default. It requires little overhead, but is a
  bit weaker than @{command nitpick}.

  \<^item> @{system_option_ref auto_sledgehammer} controls a significantly reduced
  version of @{command_ref sledgehammer}, which attempts to prove a subgoal
  using external automatic provers. See also the Sledgehammer manual @{cite
  "isabelle-sledgehammer"}.

  This tool is disabled by default, due to the relatively heavy nature of
  Sledgehammer.

  \<^item> @{system_option_ref auto_solve_direct} controls automatic use of
  @{command_ref solve_direct}, which checks whether the current subgoals can
  be solved directly by an existing theorem. This also helps to detect
  duplicate lemmas.

  This tool is \<^emph>\<open>enabled\<close> by default.


  Invocation of automatically tried tools is subject to some global policies
  of parallel execution, which may be configured as follows:

  \<^item> @{system_option_ref auto_time_limit} (default 2.0) determines the timeout
  (in seconds) for each tool execution.

  \<^item> @{system_option_ref auto_time_start} (default 1.0) determines the start
  delay (in seconds) for automatically tried tools, after the main command
  evaluation is finished.


  Each tool is submitted independently to the pool of parallel execution tasks
  in Isabelle/ML, using hardwired priorities according to its relative
  ``heaviness''. The main stages of evaluation and printing of proof states
  take precedence, but an already running tool is not canceled and may thus
  reduce reactivity of proof document processing.

  Users should experiment how the available CPU resources (number of cores)
  are best invested to get additional feedback from prover in the background,
  by using a selection of weaker or stronger tools.
\<close>


section \<open>Sledgehammer \label{sec:sledgehammer}\<close>

text \<open>
  The \<^emph>\<open>Sledgehammer\<close> panel (\figref{fig:sledgehammer}) provides a view on
  some independent execution of the Isar command @{command_ref sledgehammer},
  with process indicator (spinning wheel) and GUI elements for important
  Sledgehammer arguments and options. Any number of Sledgehammer panels may be
  active, according to the standard policies of Dockable Window Management in
  jEdit. Closing such windows also cancels the corresponding prover tasks.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.333]{sledgehammer}
  \end{center}
  \caption{An instance of the Sledgehammer panel}
  \label{fig:sledgehammer}
  \end{figure}

  The \<^emph>\<open>Apply\<close> button attaches a fresh invocation of @{command sledgehammer}
  to the command where the cursor is pointing in the text --- this should be
  some pending proof problem. Further buttons like \<^emph>\<open>Cancel\<close> and \<^emph>\<open>Locate\<close>
  help to manage the running process.

  Results appear incrementally in the output window of the panel. Proposed
  proof snippets are marked-up as \<^emph>\<open>sendback\<close>, which means a single mouse
  click inserts the text into a suitable place of the original source. Some
  manual editing may be required nonetheless, say to remove earlier proof
  attempts.
\<close>


chapter \<open>Isabelle document preparation\<close>

text \<open>
  The ultimate purpose of Isabelle is to produce nicely rendered documents
  with the Isabelle document preparation system, which is based on {\LaTeX};
  see also @{cite "isabelle-system" and "isabelle-isar-ref"}. Isabelle/jEdit
  provides some additional support for document editing.
\<close>


section \<open>Document outline\<close>

text \<open>
  Theory sources may contain document markup commands, such as @{command_ref
  chapter}, @{command_ref section}, @{command subsection}. The Isabelle
  SideKick parser (\secref{sec:sidekick}) represents this document outline as
  structured tree view, with formal statements and proofs nested inside; see
  \figref{fig:sidekick-document}.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.333]{sidekick-document}
  \end{center}
  \caption{Isabelle document outline via SideKick tree view}
  \label{fig:sidekick-document}
  \end{figure}

  It is also possible to use text folding according to this structure, by
  adjusting \<^emph>\<open>Utilities / Buffer Options / Folding mode\<close> of jEdit. The default
  mode \<^verbatim>\<open>isabelle\<close> uses the structure of formal definitions, statements, and
  proofs. The alternative mode \<^verbatim>\<open>sidekick\<close> uses the document structure of the
  SideKick parser, as explained above.
\<close>


section \<open>Citations and Bib{\TeX} entries\<close>

text \<open>
  Citations are managed by {\LaTeX} and Bib{\TeX} in \<^verbatim>\<open>.bib\<close> files. The
  Isabelle session build process and the @{tool latex} tool @{cite
  "isabelle-system"} are smart enough to assemble the result, based on the
  session directory layout.

  The document antiquotation \<open>@{cite}\<close> is described in @{cite
  "isabelle-isar-ref"}. Within the Prover IDE it provides semantic markup for
  tooltips, hyperlinks, and completion for Bib{\TeX} database entries.
  Isabelle/jEdit does \<^emph>\<open>not\<close> know about the actual Bib{\TeX} environment used
  in {\LaTeX} batch-mode, but it can take citations from those \<^verbatim>\<open>.bib\<close> files
  that happen to be open in the editor; see \figref{fig:cite-completion}.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.333]{cite-completion}
  \end{center}
  \caption{Semantic completion of citations from open Bib{\TeX} files}
  \label{fig:cite-completion}
  \end{figure}

  Isabelle/jEdit also provides some support for editing \<^verbatim>\<open>.bib\<close> files
  themselves. There is syntax highlighting based on entry types (according to
  standard Bib{\TeX} styles), a context-menu to compose entries
  systematically, and a SideKick tree view of the overall content; see
  \figref{fig:bibtex-mode}.

  \begin{figure}[htb]
  \begin{center}
  \includegraphics[scale=0.333]{bibtex-mode}
  \end{center}
  \caption{Bib{\TeX} mode with context menu and SideKick tree view}
  \label{fig:bibtex-mode}
  \end{figure}
\<close>


chapter \<open>Miscellaneous tools\<close>

section \<open>Timing\<close>

text \<open>
  Managed evaluation of commands within PIDE documents includes timing
  information, which consists of elapsed (wall-clock) time, CPU time, and GC
  (garbage collection) time. Note that in a multithreaded system it is
  difficult to measure execution time precisely: elapsed time is closer to the
  real requirements of runtime resources than CPU or GC time, which are both
  subject to influences from the parallel environment that are outside the
  scope of the current command transaction.

  The \<^emph>\<open>Timing\<close> panel provides an overview of cumulative command timings for
  each document node. Commands with elapsed time below the given threshold are
  ignored in the grand total. Nodes are sorted according to their overall
  timing. For the document node that corresponds to the current buffer,
  individual command timings are shown as well. A double-click on a theory
  node or command moves the editor focus to that particular source position.

  It is also possible to reveal individual timing information via some tooltip
  for the corresponding command keyword, using the technique of mouse hovering
  with \<^verbatim>\<open>CONTROL\<close>~/ \<^verbatim>\<open>COMMAND\<close> modifier key as explained in
  \secref{sec:tooltips-hyperlinks}. Actual display of timing depends on the
  global option @{system_option_ref jedit_timing_threshold}, which can be
  configured in \<^emph>\<open>Plugin Options~/ Isabelle~/ General\<close>.

  \<^medskip>
  The \<^emph>\<open>Monitor\<close> panel visualizes various data collections about recent
  activity of the Isabelle/ML task farm and the underlying ML runtime system.
  The display is continuously updated according to @{system_option_ref
  editor_chart_delay}. Note that the painting of the chart takes considerable
  runtime itself --- on the Java Virtual Machine that runs Isabelle/Scala, not
  Isabelle/ML. Internally, the Isabelle/Scala module \<^verbatim>\<open>isabelle.ML_Statistics\<close>
  provides further access to statistics of Isabelle/ML.
\<close>


section \<open>Low-level output\<close>

text \<open>
  Prover output is normally shown directly in the main text area or secondary
  \<^emph>\<open>Output\<close> panels, as explained in \secref{sec:output}.

  Beyond this, it is occasionally useful to inspect low-level output channels
  via some of the following additional panels:

  \<^item> \<^emph>\<open>Protocol\<close> shows internal messages between the Isabelle/Scala and
  Isabelle/ML side of the PIDE document editing protocol. Recording of
  messages starts with the first activation of the corresponding dockable
  window; earlier messages are lost.

  Actual display of protocol messages causes considerable slowdown, so it is
  important to undock all \<^emph>\<open>Protocol\<close> panels for production work.

  \<^item> \<^emph>\<open>Raw Output\<close> shows chunks of text from the \<^verbatim>\<open>stdout\<close> and \<^verbatim>\<open>stderr\<close>
  channels of the prover process. Recording of output starts with the first
  activation of the corresponding dockable window; earlier output is lost.

  The implicit stateful nature of physical I/O channels makes it difficult to
  relate raw output to the actual command from where it was originating.
  Parallel execution may add to the confusion. Peeking at physical process I/O
  is only the last resort to diagnose problems with tools that are not PIDE
  compliant.

  Under normal circumstances, prover output always works via managed message
  channels (corresponding to @{ML writeln}, @{ML warning}, @{ML
  Output.error_message} in Isabelle/ML), which are displayed by regular means
  within the document model (\secref{sec:output}). Unhandled Isabelle/ML
  exceptions are printed by the system via @{ML Output.error_message}.

  \<^item> \<^emph>\<open>Syslog\<close> shows system messages that might be relevant to diagnose
  problems with the startup or shutdown phase of the prover process; this also
  includes raw output on \<^verbatim>\<open>stderr\<close>. Isabelle/ML also provides an explicit @{ML
  Output.system_message} operation, which is occasionally useful for
  diagnostic purposes within the system infrastructure itself.

  A limited amount of syslog messages are buffered, independently of the
  docking state of the \<^emph>\<open>Syslog\<close> panel. This allows to diagnose serious
  problems with Isabelle/PIDE process management, outside of the actual
  protocol layer.

  Under normal situations, such low-level system output can be ignored.
\<close>


chapter \<open>Known problems and workarounds \label{sec:problems}\<close>

text \<open>
  \<^item> \<^bold>\<open>Problem:\<close> Odd behavior of some diagnostic commands with global
  side-effects, like writing a physical file.

  \<^bold>\<open>Workaround:\<close> Copy/paste complete command text from elsewhere, or disable
  continuous checking temporarily.

  \<^item> \<^bold>\<open>Problem:\<close> No direct support to remove document nodes from the collection
  of theories.

  \<^bold>\<open>Workaround:\<close> Clear the buffer content of unused files and close \<^emph>\<open>without\<close>
  saving changes.

  \<^item> \<^bold>\<open>Problem:\<close> Keyboard shortcuts \<^verbatim>\<open>C+PLUS\<close> and \<^verbatim>\<open>C+MINUS\<close> for adjusting the
  editor font size depend on platform details and national keyboards.

  \<^bold>\<open>Workaround:\<close> Rebind keys via \<^emph>\<open>Global Options~/ Shortcuts\<close>.

  \<^item> \<^bold>\<open>Problem:\<close> The Mac OS X key sequence \<^verbatim>\<open>COMMAND+COMMA\<close> for application
  \<^emph>\<open>Preferences\<close> is in conflict with the jEdit default keyboard shortcut for
  \<^emph>\<open>Incremental Search Bar\<close> (action @{action_ref "quick-search"}).

  \<^bold>\<open>Workaround:\<close> Rebind key via \<^emph>\<open>Global Options~/ Shortcuts\<close> according to
  national keyboard, e.g.\ \<^verbatim>\<open>COMMAND+SLASH\<close> on English ones.

  \<^item> \<^bold>\<open>Problem:\<close> On Mac OS X with native Apple look-and-feel, some exotic
  national keyboards may cause a conflict of menu accelerator keys with
  regular jEdit key bindings. This leads to duplicate execution of the
  corresponding jEdit action.

  \<^bold>\<open>Workaround:\<close> Disable the native Apple menu bar via Java runtime option
  \<^verbatim>\<open>-Dapple.laf.useScreenMenuBar=false\<close>.

  \<^item> \<^bold>\<open>Problem:\<close> Mac OS X system fonts sometimes lead to character drop-outs in
  the main text area.

  \<^bold>\<open>Workaround:\<close> Use the default \<^verbatim>\<open>IsabelleText\<close> font. (Do not install that
  font on the system.)

  \<^item> \<^bold>\<open>Problem:\<close> Some Linux/X11 input methods such as IBus tend to disrupt key
  event handling of Java/AWT/Swing.

  \<^bold>\<open>Workaround:\<close> Do not use X11 input methods. Note that environment variable
  \<^verbatim>\<open>XMODIFIERS\<close> is reset by default within Isabelle settings.

  \<^item> \<^bold>\<open>Problem:\<close> Some Linux/X11 window managers that are not ``re-parenting''
  cause problems with additional windows opened by Java. This affects either
  historic or neo-minimalistic window managers like \<^verbatim>\<open>awesome\<close> or \<^verbatim>\<open>xmonad\<close>.

  \<^bold>\<open>Workaround:\<close> Use a regular re-parenting X11 window manager.

  \<^item> \<^bold>\<open>Problem:\<close> Various forks of Linux/X11 window managers and desktop
  environments (like Gnome) disrupt the handling of menu popups and mouse
  positions of Java/AWT/Swing.

  \<^bold>\<open>Workaround:\<close> Use mainstream versions of Linux desktops.

  \<^item> \<^bold>\<open>Problem:\<close> Native Windows look-and-feel with global font scaling leads to
  bad GUI rendering of various tree views.

  \<^bold>\<open>Workaround:\<close> Use \<^emph>\<open>Metal\<close> look-and-feel and re-adjust its primary and
  secondary font as explained in \secref{sec:hdpi}.

  \<^item> \<^bold>\<open>Problem:\<close> Full-screen mode via jEdit action @{action_ref
  "toggle-full-screen"} (default keyboard shortcut \<^verbatim>\<open>F11\<close>) works on Windows,
  but not on Mac OS X or various Linux/X11 window managers.

  \<^bold>\<open>Workaround:\<close> Use native full-screen control of the window manager (notably
  on Mac OS X).
\<close>

end