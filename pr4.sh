#!/bin/bash


log_file=""
error_file=""


while getopts ":u:p:h:l:e:" opt; do
  case $opt in
    u)
      users_info;
      ;;
    p)
      processes_info;
      ;;
    h)
      help_message;
      exit 0;
      ;;
    l)
      log_file="$OPTARG";
      if [[ ! -w "$log_file" ]]; then
        echo "Error: нет прав на запись $log_file" >&2
        exit 1
      fi
      ;;
    e)
      error_file="$OPTARG";
      if [[ ! -w "$error_file" ]]; then
        echo "Error: нет прав на запись $error_file" >&2
        exit 1
      fi
      ;;
    \?)
      echo "Неверный аргумент: -$OPTARG" >&2
      help_message;
      exit 1
      ;;
    :)
      echo "Не хватает значения для аргумента -$OPTARG" >&2
      help_message;
      exit 1
      ;;
  esac
done


if [[ -z "$log_file" && -z "$error_file" && ! "$OPTIND" -eq "$#"+1 ]]; then
  help_message
  exit 1
fi


if [[ "$#" -gt 0 ]]; then
    echo "Неизвестные аргументы: $@" >&2
    help_message
    exit 1
fi


users_info() {
    if [[ -z "$log_file" ]]; then
        printf "%-20s %-30s\n" "Пользователь" "Домашний каталог"
        sort -k1 users -t: | awk '{printf "%-20s %-30s\n", $1, $3}'
    else
        sort -k1 users -t: | awk '{printf "%-20s %-30s\n", $1, $3}' > "$log_file"
    fi
}
processes_info() {
    if [[ -z "$log_file" ]]; then
        ps aux | sort -k3 | awk '{printf "%-10s\n", $2}'
    else
        ps aux | sort -k3 | awk '{printf "%-10s\n", $2}' > "$log_file"
    fi
}


help_message() {
  echo "Утилита для вывода информации о пользователях и процессах."
  echo "Использование: $0 [-u|--users] [-p|--processes] [-h|--help]"
  echo "        [-l <путь_к_файлу>] [-e <путь_к_файлу>]"
  echo "  -u, --users: выводит список пользователей и их домашние каталоги."
  echo "  -p, --processes: выводит список запущенных процессов."
  echo "  -h, --help: выводит справку."
  echo "  -l <путь_к_файлу>: перенаправляет вывод в файл."
  echo "  -e <путь_к_файлу>: перенаправляет вывод ошибок в файл."
}


if [[ ! -z "$error_file" ]]; then
  2> "$error_file"
fi


if [[ ! -z "$log_file" ]]; then
  >& "$log_file"
fi
