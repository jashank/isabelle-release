/*  Title:      Tools/jEdit/src/document_model.scala
    Author:     Fabian Immler, TU Munich
    Author:     Makarius

Document model connected to jEdit buffer -- single node in theory graph.
*/

package isabelle.jedit


import isabelle._

import scala.collection.mutable

import org.gjt.sp.jedit.Buffer
import org.gjt.sp.jedit.buffer.{BufferAdapter, BufferListener, JEditBuffer}
import org.gjt.sp.jedit.textarea.TextArea

import java.awt.font.TextAttribute


object Document_Model
{
  /* document model of buffer */

  private val key = "isabelle.document_model"

  def apply(buffer: Buffer): Option[Document_Model] =
  {
    Swing_Thread.require()
    buffer.getProperty(key) match {
      case model: Document_Model => Some(model)
      case _ => None
    }
  }

  def exit(buffer: Buffer)
  {
    Swing_Thread.require()
    apply(buffer) match {
      case None =>
      case Some(model) =>
        model.deactivate()
        buffer.unsetProperty(key)
    }
  }

  def init(session: Session, buffer: Buffer, thy_name: String): Document_Model =
  {
    exit(buffer)
    val model = new Document_Model(session, buffer, thy_name)
    buffer.setProperty(key, model)
    model.activate()
    model
  }
}


class Document_Model(val session: Session, val buffer: Buffer, val thy_name: String)
{
  /* pending text edits */

  object pending_edits  // owned by Swing thread
  {
    private val pending = new mutable.ListBuffer[Text.Edit]
    def snapshot(): List[Text.Edit] = pending.toList

    def flush(more_edits: Option[List[Text.Edit]]*)
    {
      Swing_Thread.require()
      val edits = snapshot()
      pending.clear

      val all_edits =
        if (edits.isEmpty) more_edits.toList
        else Some(edits) :: more_edits.toList
      if (!all_edits.isEmpty) session.edit_version(all_edits.map((thy_name, _)))
    }

    def init()
    {
      Swing_Thread.require()
      flush(None, Some(List(Text.Edit.insert(0, Isabelle.buffer_text(buffer)))))
    }

    private val delay_flush =
      Swing_Thread.delay_last(session.input_delay) { flush() }

    def +=(edit: Text.Edit)
    {
      Swing_Thread.require()
      pending += edit
      delay_flush()
    }
  }


  /* snapshot */

  def snapshot(): Document.Snapshot =
  {
    Swing_Thread.require()
    session.snapshot(thy_name, pending_edits.snapshot())
  }


  /* buffer listener */

  private val buffer_listener: BufferListener = new BufferAdapter
  {
    override def bufferLoaded(buffer: JEditBuffer)
    {
      pending_edits.init()
    }

    override def contentInserted(buffer: JEditBuffer,
      start_line: Int, offset: Int, num_lines: Int, length: Int)
    {
      if (!buffer.isLoading)
        pending_edits += Text.Edit.insert(offset, buffer.getText(offset, length))
    }

    override def preContentRemoved(buffer: JEditBuffer,
      start_line: Int, offset: Int, num_lines: Int, removed_length: Int)
    {
      if (!buffer.isLoading)
        pending_edits += Text.Edit.remove(offset, buffer.getText(offset, removed_length))
    }
  }


  /* activation */

  private def activate()
  {
    buffer.addBufferListener(buffer_listener)
    pending_edits.init()
    buffer.propertiesChanged()
  }

  private def deactivate()
  {
    pending_edits.flush()
    buffer.removeBufferListener(buffer_listener)
    buffer.propertiesChanged()
  }
}
