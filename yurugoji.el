;;; yurugoji.el --- Support misprinted characters in Yurugoji  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Megurine Luka

;; Author: USAMI Kenta <tadsan@zonu.me>
;; Created: 23 Dec 2022
;; Version: 1.0.0
;; Keywords: wp
;; Package-Requires: ((emacs "27.1"))
;; Homepage: https://github.com/zonuexe/yurugoji.el
;; License: GPL-3.0-or-later

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 言語沼初版の正誤表  http://www.asa21.com/news/n50730.html
;;
;;  	誤り	正しい表記
;; １４ページ１７行目	本居宣長（むてえよぬよとか）	本居宣長（もとおりのりなが）
;; ６０ページ１３行目	角回（ぉきぉあ）	角回（かくかい）
;; ６４ページ下から２行目	白鵬（ねきべい）	白鵬（はくほう）
;; ６７ページ４行目	稀勢（ゕす）の里（こて）	稀勢（きせ）の里（さと）
;; ９８ページ下から９行目	Discord（ヅァシヶｮデ）	Discord（ディスコード）
;; ９８ページ下から９行目	Slack（ショチキ）	Slack （スラック）
;; １１７ページ下から１行目	藤原不比等（びざろょぬびばて）	藤原不比等（ふじわらのふひと）
;; １５７ページ下から４行目	秋田喜美（ゕぽ）氏	秋田喜美（きみ）氏
;; １９４ページ１３行目	UTF‐８（ヤｮツァｮウビウアテ）	UTF‐８（ユーティーエフエイト）
;;

;;; Code:
(require 'cl-lib)
(require 'region-convert nil t)

(eval-and-compile
  (defconst yurugoji--cid-text
    (string-to-list
     (concat "０１２３４５６７８９ぁあぃいぅうぇえぉおかゕがきぎくぐけゖげこご"
             "さざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴ"
             "ふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをんゔ"
             "ぁぃぅぇぉゕゖっゃゅょゎァアィイゥウェエォオカヵガキギクグケヶゲ"
             "コゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒ"
             "ビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲ"
             "ンヴｧｨｩｪｫヵヶｯｬｭｮヮー｜")))

  (defun yurugoji-shift-char (char d)
    "Return shifted character in `yurugoji--cid-text' or NIL."
    (when-let (idx (cl-position char yurugoji--cid-text))
      (elt yurugoji--cid-text (+ d idx))))

  (defconst yurugoji-miss-pretty-simbols
    (cl-loop for c in yurugoji--cid-text
             for replaced = (yurugoji-shift-char c -2)
             unless (null replaced)
             collect (cons (char-to-string c) replaced)))

  (defconst yurugoji-correct-pretty-simbols
    (cl-loop for c in yurugoji--cid-text
             for replaced = (yurugoji-shift-char c 2)
             unless (null replaced)
             collect (cons (char-to-string c) replaced))))

(defvar-local yurugoji-last-prettify-symbols-mode nil)
(defvar-local yurugoji-last-pretty-simbols-alist nil)
(defvar-local yurugoji-last-prettify-symbols-compose-predicate nil)

(defvar yurugoji-correct-map
  (let ((map (make-keymap)))
    (define-key map (kbd "q") #'yurugoji-quit)
    map))

(define-minor-mode yurugoji-correct-mode
  "Yurugoji misprint."
  :lighter " 沼"
  :keymap yurugoji-correct-map
  (if yurugoji-correct-mode
      (progn
        (setq yurugoji-last-pretty-simbols-alist prettify-symbols-alist)
        (setq yurugoji-last-prettify-symbols-compose-predicate prettify-symbols-compose-predicate)
        (setq yurugoji-last-prettify-symbols-mode prettify-symbols-mode)
        (setq prettify-symbols-alist (append yurugoji-correct-pretty-simbols prettify-symbols-alist))
        (setq prettify-symbols-compose-predicate (lambda (_start _end _match) t))
        (prettify-symbols-mode +1)
        (read-only-mode +1))
    (setq prettify-symbols-alist yurugoji-last-pretty-simbols-alist)
    (setq prettify-symbols-compose-predicate yurugoji-last-prettify-symbols-compose-predicate)
    (setq yurugoji-last-pretty-simbols-alist nil)
    (setq yurugoji-last-prettify-symbols-compose-predicate nil)
    (if yurugoji-last-prettify-symbols-mode
        (prettify-symbols-mode -1))
    (read-only-mode -1)))

(defun yurugoji-quit ()
  "Quit yurugoji minor modes."
  (interactive)
  (yurugoji-correct-mode -1))

(provide 'yurugoji)
;;; yurugoji.el ends here
