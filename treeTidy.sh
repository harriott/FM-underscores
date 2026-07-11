# vim: set fdl=5:

# Joseph Harriott  sam 11 juil 2026

# bash $onGH/FM-underscores/treeTidy.sh

# (using  https://github.com/sharkdp/fd)

# Before running this:
#  fd "\'|’" # single quotes
#  fd '\s_|_\s' # spaces before/after underscores
#  fd 'â|à|è|é|ê|ë|ï|'

echo 'About to recursively fix naming issues in the whole directory tree'
# read -p " ${tpf5}- are you in the right parent directory?${tpfn} " go

mapfile -t fdH < <(fd . -u) # easier output than the  .  &  ./...  produced by  find .
mapfile -t -d $'\0' fdHs < <(for node in "${fdH[@]}";do printf '%s %s\0' "${#node}" "$node"; done | sort -z -k1,1rn -k2 | cut -zd " " -f2-) # - (stackexchange 482393) reverse sorted by length
for node in "${fdHs[@]}"; do
    ne=$(echo $node | sed 's;/$;;') # nodes equal (= no trailing / for directories)
    # echo "$ne" # should list the nodes by decreasing length
    leaf="${ne##*/}" # get the possibly messy leaf
    lm=$(echo $leaf | sed "s/^\./※/") # "leaf marked" (= temporarily mark hidden files)
    lm=$(echo $lm | sed 's/\.$/_/') # no trailing . (unlikely edge case)
    le=''; [[ $lm =~ \. ]] && le=${lm##*.} # leaf extension
    ln=${lm%.*} # leaf name
    ln="${ln//ç/c}"
    ln="${ln//œ/oe}"
    ln="${ln//ù/u}"
    ln="${ln///u}" # icon
    ln="${ln//–/-}" # en dash
    ln=$(echo $ln | sed 's/â\|à/a/g')
    ln=$(echo $ln | sed 's/Â\|À/A/g')
    ln=$(echo $ln | sed 's/è\|é\|ê\|ë/e/g') # ln='èéêë'
    ln=$(echo $ln | sed 's/È\|É\|Ê\|Ë/E/g') # ln='ÈÉÊË'
    ln=$(echo $ln | sed 's/î\|ï/i/g') # ln='îï'
    ln=$(echo $ln | sed "s/'\|\.\|:\|’/_/g") # ln="'.:’"
    ln=$(echo $ln | sed 's/[[:space:]]*-[[:space:]]*/-/g')
    ln=$(echo $ln | sed 's/[[:space:]]*_[[:space:]]*/_/g') # ln='a _ b_ c  _d e'
    ln=$(echo $ln | sed 's/[[:space:]]\+/_/g') # ln='a  bc'
    ln=$(echo $ln | sed "s/※/./") # reset hidden files
    [[ -n $le ]] && ln="$ln.$le"
    fullpath="${ne%/*}" # get the fullpath
    if [[ $leaf != $ln ]]; then
        echo "${tpf4}$fullpath${tpfn} $ln"
        mv "$node" "$fullpath/$ln"
        true
    fi
done

