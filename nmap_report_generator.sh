#!/bin/bash

# This program parses nmap results and constructs an HTML document

TITLE="Nmap Results"
CURRENT_DATE="$(date)"
TIMESTAMP="Report generated on $CURRENT_DATE by user $USER"

nmap_report () {
    # Generate raw report with nmap
    echo "[INFO] Running nmap on network $1, please wait a few seconds..."
    sudo nmap -sV "$1" > "$2"
    echo "[OK] File $2 generated successfully"
    # Split the file by empty lines
    echo "[INFO] Splitting file $2..."
    csplit "$2" '/^$/' {*} > /dev/null
    echo "[OK] File $2 split into the following files: $(ls xx*)"
    return 0
}

result_parser () {
    for i in xx*; do
        host_ip=$(grep -E 'Nmap scan report ' $i | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
        if [ $host_ip ]; then
            echo "<tr>"
            echo "<td>$host_ip</td>"
            # Get open ports
            open_ports=$(grep -E -h '^[0-9]{1,5}/(tcp|udp) open' $i | grep -E -o '^[0-9]{1,5}/(tcp|udp)')
            if [ "$open_ports" ]; then
                echo "<td>$open_ports</td>"
            else
                echo "<td>No open ports</td>"
            fi
            # Get services
            services=$(grep -E -h '^[0-9]{1,5}/(tcp|udp) open' $i | grep -E -o '  .*  ')
            if [ "$services" ]; then
                echo "<td>$services</td>"
            else
                echo "<td>No exposed services</td>"
            fi
            echo "</tr>"
        fi
    done
    return 0
}

generate_html () {
cat <<EOF

<html>
    <head>
        <title>$TITLE</title>
    </head>
    <style>
    table {
      font-family: arial, sans-serif;
      border-collapse: collapse;
      width: 100%;
    }

    td, th {
      border: 1px solid #dddddd;
      text-align: left;
      padding: 8px;
    }

    tr:nth-child(even) {
      background-color: #dddddd;
    }
    </style>
    <body>
      <h1>$TITLE</h1>
      <p1>$TIMESTAMP</p1>
      <table>
        <tr>
          <th>Host IP</th>
          <th>Open Ports</th>
          <th>Service</th>
        </tr>
        $(result_parser)
      </table>
    </body>
</html>

EOF

}

if [ $(find nmap_output.raw -mmin -30) ]; then
    while true; do
    read -p "There's nmap_output.raw file with age less than 30 minutes. Overwrite? [y/n]: " REPLY
    case "$REPLY" in
        y)  # Generate raw report with nmap
        nmap_report "192.168.239.0/24" "nmap_output.raw"
        break
        ;;
        n)  echo "[INFO] Using existing nmap_output.raw file"
        break
        ;;
    esac
    done
else
    # Generate raw report with nmap
    nmap_report "192.168.239.0/24" "nmap_output.raw"
fi

# Generate report with nmap results in HTML
echo "[INFO] Generating HTML report..."
generate_html > nmap_results.html
echo "[OK] nmap_results.html report generated successfully"