/*  Title:      Tools/jEdit/src/isabelle_session.scala
    Author:     Makarius

Access Isabelle session information via virtual file-system.
*/

package isabelle.jedit


import isabelle._

import java.awt.Component
import java.io.InputStream

import org.gjt.sp.jedit.View
import org.gjt.sp.jedit.io.{VFS => JEdit_VFS, VFSFile}
import org.gjt.sp.jedit.browser.VFSBrowser


object Isabelle_Session
{
  /* sessions structure */

  def sessions_structure(): Sessions.Structure =
    JEdit_Sessions.sessions_structure(PIDE.options.value)


  /* virtual file-system */

  val vfs_prefix = "isabelle-session:"

  class Session_Entry(name: String, path: String)
    extends VFSFile(name, path, null, VFSFile.FILE, 0L, false)
  {
    override def getExtendedAttribute(att: String): String =
      if (att == JEdit_VFS.EA_SIZE) null
      else super.getExtendedAttribute(att)
  }

  class VFS extends Isabelle_VFS(vfs_prefix,
    read = true, browse = true, low_latency = true, non_awt_session = true)
  {
    override def _listFiles(vfs_session: AnyRef, url: String, component: Component): Array[VFSFile] =
    {
      explode_url(url, component = component) match {
        case None => null
        case Some(elems) =>
          val sessions = sessions_structure()
          elems match {
            case Nil =>
              sessions.chapters.iterator.map(p => make_entry(p._1, is_dir = true)).toArray
            case List(chapter) =>
              sessions.chapters.get(chapter) match {
                case None => null
                case Some(infos) =>
                  infos.map(info =>
                  {
                    val name = chapter + "/" + info.name
                    val path =
                      Position.File.unapply(info.pos) match {
                        case Some(path) => File.platform_path(path)
                        case None => null
                      }
                    new Session_Entry(name, path)
                  }).toArray
              }
            case _ => null
          }
      }
    }
  }


  /* open browser */

  def open_browser(view: View)
  {
    val path =
      PIDE.maybe_snapshot(view) match {
        case None => ""
        case Some(snapshot) =>
          val sessions = sessions_structure()
          val session = PIDE.resources.session_base.theory_qualifier(snapshot.node_name)
          val chapter = sessions.get(session).getOrElse(Sessions.UNSORTED)
          chapter + "/" + session
      }
    VFSBrowser.browseDirectory(view, vfs_prefix + path)
  }
}
