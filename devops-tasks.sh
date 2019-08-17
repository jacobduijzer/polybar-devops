#!/usr/bin/env bash

read_settings() {
    if [ ! -f $DIR/settings.conf ]; then
        echo "The settings file (settings.conf) is missing"
        exit 1;
    fi

    # read settings
    . $DIR/settings.conf

    if [ ! -f $json_input_file ]; then
        echo "The json input file is missing"
        exit 1;
    fi

    IFS='|' read -r -a query_fields <<< "$query_fields"
}

get_task_data() {
    for field in "${query_fields[@]}"
    do
        select="$select[$field],"
    done

    query=${devops_task_query/\{\{fields\}\}/${select::-1}}
    $devops_cli work item query --instance $devsops_instance --wiql "$query" --output json > $json_data_file
}

create_header() {
    `cat $DIR/header_template.html > $html_data_file`
}

create_table_headers() {
    header="<$1>" 
    IFS='|' read -r -a array <<< "$table_header_titles"
    for element in "${array[@]}"
    do
        header="$header <th>$element</th>"
    done
    header="$header </$1>"
    echo $header >> $html_data_file
}

create_rows() {
    jq -c '.[].fields' $json_data_file | 
    while read keydata; do
        # get projectname to create clickable link
        projectName=$(echo $keydata | jq -r -c '.["System.TeamProject"]')
        row="<tr>"
        for field in "${query_fields[@]}"
        do
            row="$row<td>"
            value=$(echo $keydata | jq -r --arg FIELD $field -c '.[$FIELD]')

            # create clickable link
            # TODO: find a way to force availability of ID field
            if echo $field | grep -iqF id; then
                value="<a href='$devsops_instance/$projectName/_workitems?id=$value'>$value</a>"
            fi

            # format date field
            if echo $field | grep -iqF date; then
                value=`date "$date_format" -d "$value"`
            fi
            row="$row$value</td>"
        done
        row="$row</tr>"
        echo $row >> $html_data_file
    done
}

create_footer() {
    `cat $DIR/footer_template.html >> $html_data_file`
}

get_totals() {
    total_tasks=`jq '. | length' $json_data_file`
    case $total_tasks in
    ''|*[!0-9]*) echo error ;;
    *) echo $total_tasks ;;
    esac
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

read_settings

case "$1" in
    --popup)
        if [ "$(xdotool getwindowfocus getwindowname)" = "yad-devops" ]; then
            exit 0
        fi

        zenity --text-info --width=$window_width --height=$window_height --title="yad_devops" --filename=$html_data_file --html --cancel-label="" --ok-label="Close"

        ;;
    *)
        get_task_data

        create_header

        create_table_headers "thead"

        create_rows

        create_table_headers "tfoot"

        create_footer

        get_totals
        ;;
esac

