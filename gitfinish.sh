#Determines if we need to output the results of the git commands
verbose=0

# Error check arguments
if [ "$#" -ne 1 -a "$#" -ne 2 ]; then
    if [ "$#" -lt 1 ]; then
        printf "Not enough arguments. "
    elif [ "$#" -gt 2 ]; then
        printf "Too many arguments. "
    fi
    echo "Use 'gitfinish -h' for help."
    exit 1
else
    if [[ "$1" == "-"* ]]; then
        printf "First argument must be a commit message, not an option. "
        echo "Use 'gitfinish -h' for help."
        exit 1
    elif [ "$#" -eq 2 ]; then
        if [[ "$2" == "-"* ]]; then
            if [ "$2" != "-v" ]; then
                printf "Unrecognized command with option '$2'. "
                echo "Use 'gitfinish -h' for help."
                exit 1
            else
                verbose=1
            fi
        else
          printf "Second parameter must be '-v' or omitted. "
          echo "Use 'gitfinish -h' for help."
          exit 1
        fi
    fi
fi

# Add all the files for staging
if [ -n "$(git status --porcelain)" ]; then
  echo "Staging changes... "
  echo ""
  git add .
else
  echo "No changes to be staged. "
  exit 1
fi

# Commit all staged files with commit message
commit_message=$1
echo "Committing changes... "
echo ""
commit_output=$(git commit -m "$commit_message" 2>&1)
# Show output if verbose is enabled
if [ $verbose -eq 1 ]; then
    echo $commit_output
    echo ""
fi

# Push all changes to the origin remote of the current branch
current_branch=$(git symbolic-ref --short HEAD)
echo "Pushing to current branch... "
echo ""
push_output=$(git push origin $current_branch --porcelain 2>&1)
# Show output if verbose is enabled
if [ $verbose -eq 1 ]; then
    echo $push_output
    echo ""
fi

# Show success if successful
if [[ $push_output == *"Done"* ]]; then
    echo "SUCCESS"
else
    # Don't duplicate the output of a failed push
    if [ $verbose -eq 0 ]; then
        echo $push_output
        echo ""
    fi
fi

exit 1
