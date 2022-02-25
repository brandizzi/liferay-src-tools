# Liferay Source Tools

Here we have some tools that helps a lot to work with [Liferay source code](https://github.com/liferay/liferay-portal/).

## osgimodule

Sometimes, we have a path to a file in an OSGi module, and we need the module path. `osgimodule` returns the module's path from the file path:

    $ osgimodule modules/apps/calendar/calendar-service/src/main/java/com/liferay/calendar/internal/recurrence/RecurrenceSplitImpl.java 
    /home/adam/software/liferay-portal/modules/apps/calendar/calendar-service

Why is it useful? Glad you asked!

## fargw

`fargw` receives a list of paths to Gradle projects, and executes a command on each one of them:

    $  echo '/home/adam/software/liferay-portal/modules/apps/calendar/calendar-service
    > /home/adam/software/liferay-portal/modules/apps/site/site-impl
    > ' | fargw formatSource
    /home/adam/software/liferay-portal/modules/apps/calendar/calendar-service
    Starting a Gradle Daemon (subsequent builds will be faster)
     [...]

It is useful, for example, when you have changes in many Liferay modules, and want to execute a Gradle task in only the changed ones.
First, you get a list of modules using `osgimodule`:

    $ git diff --name-only
    modules/apps/calendar/calendar-service/src/main/java/com/liferay/calendar/internal/recurrence/RecurrenceSplit.java
    modules/apps/calendar/calendar-service/src/main/java/com/liferay/calendar/internal/recurrence/RecurrenceSplitImpl.java
    modules/apps/site/site-impl/src/main/java/com/liferay/site/internal/model/adapter/StagedGroupImpl.java
    $ git diff --name-only | xargs -L1 osgimodule
    /home/adam/software/liferay-portal/modules/apps/calendar/calendar-service
    /home/adam/software/liferay-portal/modules/apps/calendar/calendar-service
    /home/adam/software/liferay-portal/modules/apps/site/site-impl

...then you pass this list to `fargw`:

    $ git diff --name-only | xargs -L1 osgimodule | sort -u | fargw deploy
    /home/adam/software/liferay-portal/modules/apps/calendar/calendar-service
    Starting a Gradle Daemon (subsequent builds will be faster)
     [...]

## lrdeptree.sh

`lrdeptree.sh` reads paths to Liferay modules from the standard input, and prints all other Liferay modules it depens on:

    $ echo modules/apps/calendar/calendar-api/ | lrdeptree.sh 
    /home/adam/software/liferay-portal/modules/apps/calendar/calendar-api/
    /home/adam/software/liferay-portal/modules/apps/petra/petra-content/
    /home/adam/software/liferay-portal/modules/core/petra/petra-lang/
    /home/adam/software/liferay-portal/modules/core/petra/petra-sql-dsl-api/
    /home/adam/software/liferay-portal/modules/core/petra/petra-string/

This is, again, very useful when used with `fargw`. For example, my Eclipse projects often appeared as broken, because
some projects got new projects as dependences, or their dependencies had new Maven jars, which required regenerating
all `.classpath` files... I used to solve it this way:

    $ $ ls -d modules/apps/portal-search/portal-search* | lrdeptree.sh  | fargw eclipse

## How to install

Just copy the scripts to your a directory in your $PATH. You may need to make them executable.
