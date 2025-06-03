#!/usr/bin/env bash

sudo apt update && sudo apt --no-install-recommends --no-install-suggests --with-new-pkgs upgrade -y && sudo apt autoremove -y

