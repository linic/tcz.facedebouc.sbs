#!/bin/bash
comm -13 <(sort <(git-lfs ls-files | cut -d' ' -f3 | cut -d'/' -f4)) <(sort <(find -name *.tcz | cut -d'/' -f5))

