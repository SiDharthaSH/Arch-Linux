# Some more commands I found from logs of `archinstall`

Its log file does not show what modifications its making to files and what file it has created with what content :(

```
localectl set-keymap us # I have also skipped steps like these from
                        # Installation Guide of Arch Wiki 
                        # (Section: 1.5, 3.4 and many more)

chmod 700 /boot         # TODO: This may fix bootctl warnings

systemctl enable systemd-zram-setup@zram0.service # Gave me error idk why,
                                                  # zram-generator github page
                                                  # steps were the only one that worked

chpasswd --encrypted         # dont know dont care will check later

chown -R sid:sid /home/sid   # so useradd doesn't do this itself ?

ln -sf /usr/lib/systemd/user/pipewire.{service,socket} \
       /home/sid/.config/systemd/user/default.target.wants/pipewire-pulse.{service,socket}
       # I have no idea what this does, will check later when i am free
```

> [!NOTE]
> Arch Wiki, man/info and official github repo for usage examples is better than most sources
