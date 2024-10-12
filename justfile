# allow `just --fmt` with unstable features

set unstable := true

COLOR_RESET := '\033[0m'
COLOR_GREEN := '\033[1;32m'
COLOR_BLUE_ := '\033[1;34m'
COLOR_YELLO := '\033[1;33m'
COLOR_WHITE := '\033[1;37m'

default: help

@help:
    echo ""

    echo "{{ COLOR_GREEN }}Welcome to my-nvim-micro-plugins.nvim development! 🚀{{ COLOR_RESET }}"
    echo "{{ COLOR_BLUE_ }}Next, run one of these commands to get started:{{ COLOR_RESET }}"
    echo "{{ COLOR_YELLO }}  just test{{ COLOR_RESET }}"
    echo "{{ COLOR_WHITE }}    Run all tests{{ COLOR_RESET }}"

    echo "{{ COLOR_YELLO }}  just test-focus{{ COLOR_RESET }}"
    echo "{{ COLOR_WHITE }}    Run only the tests marked with #focus in the test name{{ COLOR_RESET }}"
    echo "{{ COLOR_YELLO }}  just lint{{ COLOR_RESET }}"
    echo "{{ COLOR_WHITE }}    Check the code for lint errors{{ COLOR_RESET }}"
    echo "{{ COLOR_YELLO }}  just format{{ COLOR_RESET }}"
    echo "{{ COLOR_WHITE }}    Reformat all code{{ COLOR_RESET }}"

@build:
    echo "Building project..."
    luarocks init --no-gitignore
    luarocks install busted 2.2.0-1

    just help

lint:
    selene ./lua/ ./spec/

    @if grep -r -e "#focus" --include \*.lua ./spec/; then \
      echo "\n"; \
      echo "Error: {{ COLOR_GREEN }}#focus{{ COLOR_RESET }} tags found in the codebase.\n"; \
      echo "Please remove them to prevent issues with not accidentally running all tests."; \
      exit 1; \
    fi

test:
    luarocks test --local

test-focus:
    luarocks test --local -- --filter=focus

format:
    stylua lua/ spec/ packages/integration-tests/

check: lint test format

