# p-reg
Priority registration simulation

## Import the first thousand sections on offer

Followed the steps below to create the first 1,000 section picos, for the purpose of seeing if the rate of creation drops off dramatically after the first few hundred, as noticed in previous experiments of this type:

1. Cloned the [registration](https://github.com/b1conrad/registration) repo to have access to its data files
2. Noted that it describes 44,486 add/drop events from 6,680 students for 4,624 sections (of 5,393 on offer), with the first three counts coming from `data/simulate` and the last from `data/si` which contains a list of sections on offer (each line of the form (tab-separated) section_id TAB places_limit)
    ```
    $ wc ../registration/data/simulate
       44486   98766 1921041 data/simulate
    $ cat ../registration/data/simulate | cut -d ',' -f 1 | sort -u | wc
        6680    6680   66800
    $ cat ../registration/data/simulate | cut -d ',' -f 2 | sort -u | wc
        4624   10065   52532
    $ wc ../registration/data/si
        5393   17129   77678 ../registration/data/si
    ```
3. Started a v1.3.0 pico engine (which had been used for many other experiments)
4. Manually created a new child pico from the root pico and manually created an `allow-all` channel (with ECI `cm19inpfk00msnzs46cgsaxlh`)
5. Converted the first 10 lines of `data/si` into `curl` commands using `sed`:
    ```
    $ head ../registration/data/si\
     | sed "s+^.*$+curl -G localhost:3000/c/cm19...xlh/event/sections/init --data-urlencode 'line=&'; echo; date+"\
     >input/batch1
    $ head -1 input/batch1
    curl -G localhost:3000/c/cm19...xlh/event/sections/init --data-urlencode 'line=A HTG 100-1	30'; echo; date
    ```
6. Ran the first of the `curl` commands:
    ```
    $ head -1 input/batch1 | bash
    "cm19mmnja00t0nzs46vv1c5bg"
    Thu Sep 19 12:29:56 MDT 2024
    ```
7. Examined the Logging tab for the new pico to see how the incoming event looks
8. Created a new ruleset `krl/sections.krl` and began working on it, repeatedly running `curl` scripts and checking the resulting child picos until satisfied, creating and then manually deleting a few child picos at a time
9. Converted the first 1,000 lines of `data/si` into `curl` commands
    ```
    $ head -1000 ../registration/data/si\
     | sed "s+^.*$+curl -G localhost:3000/c/cm19...xlh/event/sections/init --data-urlencode 'line=&'; echo; date+"\
     >input/batch1000
    APENG-B1CONRAD:p-reg bruceconrad$ bash input/batch1000
    "cm19qlrry0384nzs4d2hf24qe"
    Thu Sep 19 14:21:13 MDT 2024
    ...
    "cm19qm0up0arunzs46d050piz"
    Thu Sep 19 14:21:25 MDT 2024
    "cm19qm0v10as2nzs401v62zck"
    Thu Sep 19 14:21:25 MDT 2024
    ```
10. Produced the rate of creation with this script (deciding that this represents a fairly constant creation rate of about 80 per second):
    ```
    $ pbpaste | grep Thu | uniq -c
      13 Thu Sep 19 14:21:13 MDT 2024
      83 Thu Sep 19 14:21:14 MDT 2024
      88 Thu Sep 19 14:21:15 MDT 2024
      85 Thu Sep 19 14:21:16 MDT 2024
      87 Thu Sep 19 14:21:17 MDT 2024
      85 Thu Sep 19 14:21:18 MDT 2024
      89 Thu Sep 19 14:21:19 MDT 2024
      86 Thu Sep 19 14:21:20 MDT 2024
      86 Thu Sep 19 14:21:21 MDT 2024
      85 Thu Sep 19 14:21:22 MDT 2024
      84 Thu Sep 19 14:21:23 MDT 2024
      82 Thu Sep 19 14:21:24 MDT 2024
      47 Thu Sep 19 14:21:25 MDT 2024
    ```
11. Modified the ruleset to delete child picos in order to cleanup the pico engine

## Import all of the sections on offer

Followed the steps below in a fresh pico engine to import all of the sections on offer. 
Before doing the actual import, left the developer UI in the Testing tab for the "p-reg" pico, so that the event `sections:cleanup_requested` could be sent with a single mouse click.

1. Preparation: have git ignore `.pico-engine/` so that it would be possible to start a new pico engine instance using this local directory as home
2. Start the pico engine, create a "p-reg" pico 
3. Using the developer UI, add a new channel, with ECI `cm1dlnxce000xpvs43w5218t9`
4. Using the developer UI, install the `sessions.krl` ruleset in the pico
5. Create input/batch file
    ```
    $ cat ../registration/data/si\
     | sed "s+^.*$+curl -Gs localhost:3000/c/cm1…8t9/event/sections/init --data-urlencode 'line=&'; echo; date+"\
     >input/batch
    ```
6. Run the import and convert the output into a comma-separated file showing number created per second
    ```
    $ bash input/batch >input/timing
    $ grep Sep input/timing | wc
    5393   32358  156397
    $ cat input/timing | grep Sep | uniq -c\
     | sed "s/^ *//"\
     | sed "s/ ... ... .. /,/"\
     | sed "s/ MDT.*//"\
     | pbcopy 
    ```
7. Paste into a spreadsheet and create a chart (see [p-reg import timing](https://docs.google.com/spreadsheets/d/1WneCOB4WB3V7uCeBmkd_rwDwEdflzE7HmZwL9rV6LYw/edit?usp=sharing))
8. Try opening the developer UI: took about six minutes, and changing from one tab to another was sluggish
9. Delete all the child picos ([four didn’t get deleted!](https://github.com/b1conrad/p-reg/issues/3)) and then the developer UI is again usable

### Repeat the import of all sections on offer

The first time, all we did was create a child pico.
This time, we sent the newly created pico an event to install a `section` ruleset, which captures the class size limit into an entity variable.

1. Flushed the `sections` ruleset in the "p-reg" pico
2. Repeated steps 6-9 of the previous, with very similar results (see tab "timing2" of [p-reg import timing](https://docs.google.com/spreadsheets/d/1WneCOB4WB3V7uCeBmkd_rwDwEdflzE7HmZwL9rV6LYw/edit?usp=sharing)),
and timing the restart of the pico engine more carefully
    ```
    $ date # visit localhost:3000
     Thu Sep 26 07:19:38 MDT 2024
    $ ls -lrt .pico-engine/pico-engine.log
     -rw-r--r--  1 bruceconrad  staff  16077025 Sep 26 07:22 .pico-engine/pico-engine.log
    $ ls -lrt .pico-engine/pico-engine.log
     -rw-r--r--  1 bruceconrad  staff  19233117 Sep 26 07:23 .pico-engine/pico-engine.log
    $ date
     Thu Sep 26 07:26:29 MDT 2024
    ```
4. The same four child picos were not actually deleted!


## Perform all of the registration events
