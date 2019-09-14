;;; -*- lexical-binding: t; -*-

;; Copyright (C) 2018-2019 Mathias Fleury

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and-or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Code:

(require 'isar-goal-mode)
(require 'lsp-decorations)

(require 'dom)
(eval-when-compile (require 'subr-x))

(defvar isar-output-buffer nil)
(defvar isar-proof-cases-content nil)


;; TODO
;;
;;   - find a big example to play with the recursive function to
;; optimise the code.
;;
;;   - benchmark if it makes sense to move the let for node and
;; children outside the cond in order to build a single jump table.
;;
;;   - TCO might be faster, but it is not trivial to express the
;; function that way. The mapconcat could be replaced by a side-effect
;; insertion on the buffer. propretize can become add-text-properties
;; with remembering of the initial point. Basically, the function
;; would have to have its own stack, making it harder to understand
;; and maintain.
;;
;;   - however, TCO might be required for very deep terms anyway.
;;
;;   - maybe remove the let children that is not optimised away.
;;
;;
;; The (cond ...) compiles down to a jump table, except for the
;; entries that contains (or (eq ...) (eq ...)). Therefore, I
;; duplicate entries.
;;
(defun isar-parse-output (content)
  "The function iterates over the dynamic output generated by
Isabelle (after preprocessing), in order to generate a goal that
must be printed in Emacs with the syntax highlighting.

This is function is important for performance (not as critical as
the decorations), because goals can become arbitrary long. Remark
that I have not really tried to optimise it yet. Even if the
function is less critical, emacs is single threaded and all these
functions adds up. So any optimisation would help."
  ;;(message "content = %s" content)
  (cond
   ((eq content nil) nil)
   ((stringp content)
    ;; (message "stringp %s" content)
    content)
   ((not (listp content))
    (message "unrecognised")
    (format "%s" content))
   (t
    (pcase (dom-tag content)
      ('html
       (mapconcat 'isar-parse-output (dom-children content) ""))
      ('xmlns "")
      ('meta "")
      ('link "")
      ('xml_body "")

      ('head
       (isar-parse-output (car (last (dom-children content)))))
      ('body
       (mapconcat 'isar-parse-output (dom-children content) ""))

      ('block
       (concat
	(if (dom-attr content 'indent) " " "")
	(mapconcat 'isar-parse-output (dom-children content) "")))

      ('class
       (mapconcat 'isar-parse-output (dom-children content) ""))
      ('pre
       (mapconcat 'isar-parse-output (dom-children content) ""))

      ('state_message
       (mapconcat 'isar-parse-output (dom-children content) ""))

      ('information_message
       (concat "\n\n"
	       (propertize (concat (mapconcat 'isar-parse-output (dom-children content) "") "\n")
			   'font-lock-face (cdr (assoc "dotted_information" isar-get-font)))))

      ('tracing_message ;; TODO Proper colour
       (propertize (concat (mapconcat 'isar-parse-output (dom-children content) "") "\n")
		   'font-lock-face (cdr (assoc "dotted_information" isar-get-font))))

      ('warning_message
       (propertize (concat (mapconcat 'isar-parse-output (dom-children content) "") "\n")
		   'font-lock-face (cdr (assoc "dotted_warning" isar-get-font))))

      ('error_message
       (propertize (concat (mapconcat 'isar-parse-output (dom-children content) "") "\n")
		   'font-lock-face (cdr (assoc "dotted_warning" isar-get-font))))

      ('text_fold
       (mapconcat 'isar-parse-output (dom-children content) ""))

      ('subgoal
       (mapconcat 'isar-parse-output (dom-children content) ""))

      ('span
       (format "%s" (car (last (dom-children content)))))

      ('position
       (isar-parse-output (car (last (dom-children content)))))

      ('keyword1
       (propertize (isar-parse-output (car (last (dom-children content))))
		   'font-lock-face (cdr (assoc "text_keyword1" isar-get-font))))

      ('intensify
       (propertize (isar-parse-output (car (last (dom-children content))))
		   'font-lock-face (cdr (assoc "background_intensify" isar-get-font))))

      ('keyword2
       (propertize (isar-parse-output (car (last (dom-children content))))
		   'font-lock-face (cdr (assoc "text_keyword2" isar-get-font))))

      ('keyword3
       (propertize (isar-parse-output (car (last (dom-children content))))
		   'font-lock-face (cdr (assoc "text_keyword3" isar-get-font))))

      ('keyword4
       (propertize (isar-parse-output (car (last (dom-children content))))
		   'font-lock-face (cdr (assoc "text_keyword4" isar-get-font))))

      ('fixed ;; this is used to enclose other variables
       (mapconcat 'isar-parse-output (dom-children content) ""))

      ('free
       (propertize (mapconcat 'isar-parse-output (dom-children content) "")
		   'font-lock-face (cdr (assoc "text_free" isar-get-font))))

      ('tfree
       (propertize (mapconcat 'isar-parse-output (dom-children content) "")
		   'font-lock-face (cdr (assoc "text_tfree" isar-get-font))))

      ('tvar
       (propertize (mapconcat 'isar-parse-output (dom-children content) "")
		   'font-lock-face (cdr (assoc "text_tvar" isar-get-font))))

      ('var
       (propertize (mapconcat 'isar-parse-output (dom-children content) "")
		   'font-lock-face (cdr (assoc "text_var" isar-get-font))))

      ('bound
       (propertize (mapconcat 'isar-parse-output (dom-children content) "")
		   'font-lock-face (cdr (assoc "text_bound" isar-get-font))))

      ('skolem
       (propertize (mapconcat 'isar-parse-output (dom-children content) "")
		   'font-lock-face (cdr (assoc "text_skolem" isar-get-font))))

      ('sendback ;; TODO handle properly
       (concat (mapconcat 'isar-parse-output (dom-children content) "") ""))

      ('bullet
       (concat "\n- " (mapconcat 'isar-parse-output (dom-children content) "") "")) ;; TODO proper utf8

      ('language
       (mapconcat 'isar-parse-output (dom-children content) ""))
      ('literal
       (mapconcat 'isar-parse-output (dom-children content) ""))

      ('delimiter
       (concat (mapconcat 'isar-parse-output (dom-children content) "") ""))

      ('entity
       (concat (mapconcat 'isar-parse-output (dom-children content) "") ""))

      ('writeln_message
       (propertize (concat (mapconcat 'isar-parse-output (dom-children content) "") "\n")
		   'font-lock-face (cdr (assoc "dotted_writeln" isar-get-font))))

      ('paragraph
       (concat "" (mapconcat 'isar-parse-output (dom-children content) "") ""))

      ('item
       ;;(message "%s" (mapconcat 'isar-parse-output (dom-children content) ""))
       (concat (mapconcat 'isar-parse-output (dom-children content) "") "\n"))

      ('break
       (let ((children (mapcar (lambda (a) (string-remove-suffix "'" (string-remove-prefix "'" a))) (dom-children content))))
	 (concat
	  (if (dom-attr content 'width) " " "")
	  (if (dom-attr content 'line) "\n" "")
	  (mapconcat 'isar-parse-output children ""))))

      ('xml_elem
       (mapconcat 'isar-parse-output (dom-children content) ""))

      ('sub (format "\\<^sub>%s" (car (last (dom-children content)))))
      ('sup (format "\\<^sup>%s" (car (last (dom-children content)))))

      (_
       (if (listp (dom-tag content))
	   (progn
	     (message "unrecognised node %s" (dom-tag content))
	     (concat
	      (format "%s" (dom-tag content))
	      (mapconcat 'isar-parse-output (dom-children content) "")))
	 (progn
	   (message "unrecognised content %s; node is: %s" content (dom-tag content))
	   (concat (format "%s" (dom-tag content))))))))))

(defun replace-regexp-lisp (REGEXP TO-STRING)
  "replace-regexp as indicated in the help"
   (while (re-search-forward REGEXP nil t)
    (replace-match TO-STRING nil nil)))


(defun isar-update-output-buffer (content)
  "Updates the output progress"
  (setq parsed-content nil)
  (let ((inhibit-read-only t))
    (save-excursion
      (with-current-buffer isar-output-buffer
	(setq parsed-content
	      (with-temp-buffer
		(if content
		    (progn
		      (insert content)
		      ;; Isabelle's HTML and emacs's HMTL disagree, so
		      ;; we preprocess the output.
		      (goto-char (point-min))
		      (replace-regexp-lisp "\n\\( *\\)" "<break line = 1>'\\1'</break>")
		      (goto-char (point-min))
		      (replace-regexp-lisp "\\(\\w\\)>\\( *\\)<" "\\1><break>'\\2'</break><")
		      ;;(message (buffer-string))
		      ;;(message content)
		      ;;(message "%s"(libxml-parse-html-region  (point-min) (point-max)))
	              (setq parsed-content (libxml-parse-html-region  (point-min) (point-max)))
		  )
		)))
;;	(message  "parsed output = %s" (isar-parse-output parsed-content))
	(setf (buffer-string) (isar-parse-output parsed-content))
	(goto-char (point-min))
	(ignore-errors
	  (progn
	    (search-forward "Proof outline with cases:") ;; TODO this should go to isar-parse-output
	    (setq isar-proof-cases-content (buffer-substring (point) (point-max)))))))))

(defun lsp-isar-initialize-output-buffer ()
  (setq isar-output-buffer (get-buffer-create "*isar-output*"))
  (save-excursion
    (with-current-buffer isar-output-buffer
      (read-only-mode t)
      (isar-goal-mode))))

(defun lsp-isar-insert-cases ()
    "insert the last seen outline"
  (interactive)
  (insert isar-proof-cases-content))


(modify-coding-system-alist 'file "*isar-output*" 'utf-8-auto)

(provide 'lsp-output)
