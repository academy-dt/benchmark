# Minimal monitoring script

Runs an given command and monitors a specified comm process, writing metrics into an `app.log` file.

Once the underlying process is killed, and `pidof <comm>` fails, the monitor stops.

You can then run `gnuplot app.plt` to create a nice graph from the `app.log` records.