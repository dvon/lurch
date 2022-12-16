BEGIN {
	# for dot output
        # print "digraph dg\n{"
      }

/^never/ { ba = 0 }

/^state/ { if (ba)
             {
               gsub("acc", "=acc")
               now = $2
             }
         }

/->/ { if (ba)
         {
           gsub("acc", "=acc")
	   split($0, a, " -> ")

	   # for Lurch output
           print "n: " now ". (" a[1] "); -; " a[2] "."

	   # for dot output
           # print "  \"" now "\"->\"" a[2] "\" [label=\"" a[1] "\"];"
         }
     }

/./ { if (ba)
        for (i = 1; i <= NF; i++)
          if ($i !~ "(^state$)|(^init$)|(^->$)|(^T[0-9]+_.*$)|(^=?accept_.*$)|(^0|1$)|(^&$)|(^[|]$)")
            {
	      gsub("!", "")
	      defs[$i] = 1
	    }
    }

/^Buchi automaton after simplification/ { ba = 1 }

/accept_init:/ { print "=init" }

# for Lurch output
END { for (i in defs) print "#define " i }

# for dot output
# END { print "}" }
