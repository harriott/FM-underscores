# vim: set fdl=5:

# Joseph Harriott  Tue 21 Apr 2026
# bash $onGH/FM-underscores/treeTidy.sh

# In the fresh rclone:
#  fd "\'|’" # single quotes
#  fd '\s_|_\s' # spaces before/after underscores
#  fd 'â|à|è|é|ê|ë|ï|'

echo 'About to recursively fix naming issues in the whole directory tree'
read -p " ${tpf5}- are you in the right parent directory?${tpfn} " go

mapfile -t found < <(find .)
# for node in "${found[@]}"; do echo "$node"; done
readarray -td $'\0' sorted < <(for node in "${found[@]}";do printf '%s %s\0' "${#node}" "$node"; done | sort -bz -k1,1rn -k2 | cut -zd " " -f2-)
for node in "${sorted[@]}"; do
    leaf="${node##*/}" # get the leaf
    nl="${leaf//ç/c}" # new leaf
    nl="${nl//ç/c}"
    nl="${nl//œ/oe}"
    nl="${nl//ù/u}"
    nl="${nl///u}" # icon
    nl="${nl//–/-}" # en dash
    nl=$(echo $nl | sed 's/â\|à/a/g')
    nl=$(echo $nl | sed 's/Â\|À/A/g')
    nl=$(echo $nl | sed 's/è\|é\|ê\|ë/e/g') # nl='èéêë'
    nl=$(echo $nl | sed 's/È\|É\|Ê\|Ë/E/g') # nl='ÈÉÊË'
    nl=$(echo $nl | sed 's/î\|ï/i/g') # nl='îï'
    nl=$(echo $nl | sed "s/'\|\.\|:\|’/_/g") # nl="'.:’"
    nl=$(echo $nl | sed 's/[[:space:]]*_[[:space:]]*/_/g') # nl='a _ b_ c  _d e'
    nl=$(echo $nl | sed 's/[[:space:]]\+/_/g') # nl='a  bc'
    fullpath="${node%/*}" # get the fullpath
    if ! [[ $leaf == $nl ]] && ! [[ $node == '.' ]]; then
        echo "${tpf4}$fullpath${tpfn} $nl"
        # echo "$node -> $nl"
        mv "$node" "$fullpath/$nl"
    fi
done

