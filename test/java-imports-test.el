;;; java-imports-test.el --- tests for java imports

;; Copyright (C) 2015  Matthew Lee Hinman

;;; Code:

(require 'ert)
(require 'kotlin-mode)
(load-file "java-imports.el")


(ert-deftest t-java-import-for-line ()
  (with-temp-buffer
    (insert "import java.util.List;")
    (should (equal (java-imports-import-for-line)
                   "java.util.List")))
  (with-temp-buffer
    (insert "     import org.writequit.Thingy;  ")
    (should (equal (java-imports-import-for-line)
                   "org.writequit.Thingy"))))

(ert-deftest t-kotlin-import-for-line ()
  (with-temp-buffer
    (insert "import java.util.List")
    (should (equal (java-imports-import-for-line)
                   "java.util.List")))
  (with-temp-buffer
    (insert "     import org.writequit.Thingy  ")
    (should (equal (java-imports-import-for-line)
                   "org.writequit.Thingy"))))

(ert-deftest t-java-go-to-imports-start ()
  ;; both package and imports present? Goto to the first import line beginning
  (with-temp-buffer
    (insert "package mypackage;\n")
    (insert "\n")
    (insert "import java.util.List;\n")
    (insert "import java.util.ArrayList;\n")
    (insert "\n\n")
    (java-imports-go-to-imports-start)
    (should (equal (line-number-at-pos) 3)))

  ;; no package and imports present? First import line
  (with-temp-buffer
    (insert "\n")
    (insert "\n")
    (insert "\n")
    (insert "import java.util.List;\n")
    (insert "import java.util.ArrayList;\n")
    (insert "\n\n")
    (java-imports-go-to-imports-start)
    (should (equal (line-number-at-pos) 4)))

  ;; package present, no imports? Add a correct import place, keeping the empty
  ;; lines
  (with-temp-buffer
    (insert "\n")
    (insert "package mypackage;\n")
    (insert "\n")
    (insert "\n")
    (insert "class A {}\n")
    (java-imports-go-to-imports-start)
    (should (equal (line-number-at-pos) 4))
    (should (equal (count-lines (point-min) (point-max)) 7)))

  ;; no package, no imports? Stay in the beginning, add lines required
  (with-temp-buffer
    (insert "\n")
    (insert "\n")
    (insert "\n")
    (insert "class A {}\n")
    (java-imports-go-to-imports-start)
    (should (equal (line-number-at-pos) 1))
    (should (equal (count-lines (point-min) (point-max)) 5))))

(ert-deftest t-kotlin-go-to-imports-start ()
  ;; both package and imports present? Goto to the first import line beginning
  (with-temp-buffer
    (insert "package mypackage\n")
    (insert "\n")
    (insert "import java.util.List\n")
    (insert "import java.util.ArrayList\n")
    (insert "\n\n")
    (java-imports-go-to-imports-start)
    (should (equal (line-number-at-pos) 3)))

  ;; no package and imports present? First import line
  (with-temp-buffer
    (insert "\n")
    (insert "\n")
    (insert "\n")
    (insert "import java.util.List\n")
    (insert "import java.util.ArrayList\n")
    (insert "\n\n")
    (java-imports-go-to-imports-start)
    (should (equal (line-number-at-pos) 4)))

  ;; package present, no imports? Add a correct import place, keeping the empty
  ;; lines
  (with-temp-buffer
    (insert "\n")
    (insert "package mypackage\n")
    (insert "\n")
    (insert "\n")
    (insert "class A {}\n")
    (java-imports-go-to-imports-start)
    (should (equal (line-number-at-pos) 4))
    (should (equal (count-lines (point-min) (point-max)) 7)))

  ;; no package, no imports? Stay in the beginning, add lines required
  (with-temp-buffer
    (insert "\n")
    (insert "\n")
    (insert "\n")
    (insert "class A {}\n")
    (java-imports-go-to-imports-start)
    (should (equal (line-number-at-pos) 1))
    (should (equal (count-lines (point-min) (point-max)) 5))))

(ert-deftest t-java-add-imports ()
  (with-temp-buffer
    (setq-local java-imports-find-block-function
                #'java-imports-find-place-after-last-import)
    (insert "package mypackage;\n\n")
    (insert "import java.util.List;\n\n\n")
    (java-imports-add-import-with-package "ArrayList" "java.util")
    (should
     (equal
      (buffer-string)
      (concat
       "package mypackage;\n\n"
       "import java.util.List;\n"
       "import java.util.ArrayList;\n\n\n"))))

  ;; Test for annotation importing
  (with-temp-buffer
    (insert "package mypackage;\n\n")
    (insert "import java.util.List;\n\n\n")
    (java-imports-add-import-with-package "@MyAnnotation" "org.foo")
    (should
     (equal
      (buffer-string)
      (concat
       "package mypackage;\n\n"
       "import java.util.List;\n"
       "import org.foo.MyAnnotation;\n\n\n"))))

  (with-temp-buffer
    (setq-local java-imports-find-block-function
                #'java-imports-find-place-sorted-block)
    (insert "package mypackage;\n\n")
    (insert "import java.util.List;\n\n\n")
    (java-imports-add-import-with-package "ArrayList" "java.util")
    (should
     (equal
      (buffer-string)
      (concat
       "package mypackage;\n\n"
       "import java.util.ArrayList;\n"
       "import java.util.List;\n\n\n")))))

(ert-deftest t-java-add-duplicate-import ()
  (with-temp-buffer
    (setq-local java-imports-find-block-function
                #'java-imports-find-place-sorted-block)
    (insert "package mypackage;\n\n")
    (insert "import java.util.List;\n\n\n")
    (should-error
     (java-imports-add-import-with-package "List" "java.util")
     :type 'user-error)))

(ert-deftest t-kotlin-add-imports ()
  (with-temp-buffer
    (kotlin-mode)
    (setq-local java-imports-find-block-function
                #'java-imports-find-place-after-last-import)
    (insert "package mypackage\n\n")
    (insert "import java.util.List\n\n\n")
    (java-imports-add-import-with-package "ArrayList" "java.util")
    (should
     (equal
      (buffer-string)
      (concat
       "package mypackage\n\n"
       "import java.util.List\n"
       "import java.util.ArrayList\n\n\n"))))

  ;; Test for annotation importing
  (with-temp-buffer
    (kotlin-mode)
    (insert "package mypackage\n\n")
    (insert "import java.util.List\n\n\n")
    (java-imports-add-import-with-package "@MyAnnotation" "org.foo")
    (should
     (equal
      (buffer-string)
      (concat
       "package mypackage\n\n"
       "import java.util.List\n"
       "import org.foo.MyAnnotation\n\n\n"))))

  (with-temp-buffer
    (kotlin-mode)
    (setq-local java-imports-find-block-function
                #'java-imports-find-place-sorted-block)
    (insert "package mypackage\n\n")
    (insert "import java.util.List\n\n\n")
    (java-imports-add-import-with-package "ArrayList" "java.util")
    (should
     (equal
      (buffer-string)
      (concat
       "package mypackage\n\n"
       "import java.util.ArrayList\n"
       "import java.util.List\n\n\n")))))

(ert-deftest t-kotlin-add-duplicate-import ()
  (with-temp-buffer
    (setq-local java-imports-find-block-function
                #'java-imports-find-place-sorted-block)
    (insert "package mypackage\n\n")
    (insert "import java.util.List\n\n\n")
    (should-error
     (java-imports-add-import-with-package "List" "java.util")
     :type 'user-error)))

(ert-deftest t-java-list-imports ()
  (with-temp-buffer
    (insert "package mypackage;\n")
    (insert "\n")
    (insert "import org.Thing;\n")
    (insert "\n")
    (insert "import java.util.List;\n")
    (insert "import java.util.ArrayList;\n")
    (insert "\n")
    (insert "public class Foo {}")
    (should
     (equal
      (java-imports-list-imports)
      '("org.Thing" "java.util.List" "java.util.ArrayList")))))

(ert-deftest t-kotlin-list-imports ()
  (with-temp-buffer
    (insert "package mypackage\n")
    (insert "\n")
    (insert "import org.Thing\n")
    (insert "import java.util.List\n")
    (insert "import java.util.ArrayList\n")
    (insert "\n")
    (insert "public class Foo {}")
    (should
     (equal
      (java-imports-list-imports)
      '("org.Thing" "java.util.List" "java.util.ArrayList")))))

(ert-deftest t-pkg-and-class-from-import ()
  (should
   (equal (java-imports-get-package-and-class "java.util.Map")
          '("java.util" "Map")))
  (should
   (equal (java-imports-get-package-and-class "org.foo.bar.baz.ThingOne")
          '("org.foo.bar.baz" "ThingOne"))))

(ert-deftest t-java-scan-file ()
  (let ((java-imports-cache-name "java-imports-test/tmp")
        (inhibit-message t)
        (c-initialization-hook nil)
        (c-mode-common-hook nil)
        (java-mode-hook nil))
    (unwind-protect
        (with-temp-buffer
          (insert "package mypackage;\n")
          (insert "\n")
          (insert "import org.Thing;\n")
          (insert "\n")
          (insert "import java.util.List;\n")
          (insert "import java.util.ArrayList;\n")
          (insert "\n")
          (insert "public class Foo {}")
          (java-mode)
          (java-imports-scan-file)
          (let ((cache (pcache-repository java-imports-cache-name)))
            (should
             (equal
              (pcache-get cache 'Thing)
              "org"))
            (should
             (equal
              (pcache-get cache 'List)
              "java.util"))
            (should
             (equal
              (pcache-get cache 'ArrayList)
              "java.util"))
            (should
             (equal
              (pcache-get cache 'Foo)
              "mypackage"))))
      (pcache-destroy-repository java-imports-cache-name))))

(ert-deftest t-kotlin-scan-file ()
  (let ((java-imports-cache-name "java-imports-test/tmp")
        (inhibit-message t)
        (c-initialization-hook nil)
        (c-mode-common-hook nil)
        (kotlin-mode-hook nil))
    (unwind-protect
        (with-temp-buffer
          (insert "package mypackage\n")
          (insert "\n")
          (insert "import org.Thing\n")
          (insert "\n")
          (insert "import java.util.List\n")
          (insert "import java.util.ArrayList\n")
          (insert "\n")
          (insert "public class Foo {}")
          (kotlin-mode)
          (java-imports-scan-file)
          (let ((cache (pcache-repository java-imports-cache-name)))
            (should
             (equal
              (pcache-get cache 'Thing)
              "org"))
            (should
             (equal
              (pcache-get cache 'List)
              "java.util"))
            (should
             (equal
              (pcache-get cache 'ArrayList)
              "java.util"))
            (should
             (equal
              (pcache-get cache 'Foo)
              "mypackage"))))
      (pcache-destroy-repository java-imports-cache-name))))

;; End:
;;; java-imports-test.el ends here
