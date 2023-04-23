if [ "$(uname -s)" != "Linux" ]; then
    echo "Error: This script can only be run on a Linux OS" >&2
    exit 1
fi

# Check if the /proc/stat file exists
if [ ! -f "/proc/stat" ]; then
    echo "Error: /proc/stat does not exist" >&2
    exit 1
fi

# Check if the /proc/stat file has the correct format
if ! grep -qP "^(cpu|cpu\d+)\s+(\d+\s+){7}\d+$" /proc/stat; then
    echo "Error: /proc/stat has the wrong format" >&2
    exit 1
fi

# check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: this script must be run as root" >&2
    exit 1
fi

# check if the script is already running
if [ -f /var/run/cpu_monitor.pid ]; then
    echo "Error: this script is already running" >&2
    exit 1
fi

# create a file that contains the pid of the script
echo "$$" > /var/run/cpu_monitor.pid; echo_exit_status=$?
if [ $echo_exit_status -ne 0 ]; then
    echo "Error: could not create /var/run/cpu_monitor.pid" >&2
    exit 1
fi

# remove the file that contains the pid of the script when the script finishes
rm -f /var/run/cpu_monitor.pid; rm_exit_status=$?
if [ $rm_exit_status -ne 0 ]; then
    echo "Error: could not remove /var/run/cpu_monitor.pid" >&2
    exit 1
fi

# log file
log_file="/var/log/cpu_monitor.log"

