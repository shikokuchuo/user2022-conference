# ------------------------------------ #
# Welcome to the nanonext / mirai demo #
#          @ userR! 2022               #
# ------------------------------------ #
library(nanonext)

# ------------------------------- #
# Using object-oriented interface #
# ------------------------------- #
n1 <- nano("req", dial = "inproc://nano")
n2 <- nano("rep", listen = "inproc://nano")

n1$send("test")
n2$recv()

n1$close()
n2$close()

# -------------------------- #
# Using functional interface #
# -------------------------- #
s1 <- socket("push", listen = "tcp://127.0.0.1:5555")
s2 <- socket("pull", dial = "tcp://127.0.0.1:5555")

send(s1, "hello world!")
recv(s2)

s1 |> send("I'm using a pipe!", echo = FALSE)
s2 |> recv(keep.raw = FALSE)

close(s1)
close(s2)

# ---------------- #
# Demo of Async >> #
# ---------------- #
s1 <- socket("pair", listen = "inproc://nano")
s2 <- socket("pair", dial = "inproc://nano")

# an async receive is requested, but no messages are waiting (yet to be sent)
msg <- recv_aio(s2)
msg
msg$data

# sending a message now
res <- send_aio(s1, data.frame(a = 1, b = 2))
res
res$result

# now that a message has been sent, the 'recvAio' resolves automatically
msg$data
msg$raw

close(s1)
close(s2)

# ------------------------------- #
# Demo of Cross-language exchange #
# with Python NumPy >>            #
# ------------------------------- #
n <- nano("pair", dial = "ipc:///tmp/nanonext.socket")
n$send(c(1.1, 2.2, 3.3, 4.4, 5.5), mode = "raw")

n$recv(mode = "double", block = TRUE)

n$close()

# ----------------------- #
# Demo of pub / sub       #
# Scalability Protocol >> #
# ----------------------- #
pub <- socket("pub", listen = "inproc://nanobroadcast")
sub <- socket("sub", dial = "inproc://nanobroadcast")

sub |> subscribe(topic = "examples")

pub |> send(c("examples", "this is an example"), mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)

pub |> send("examples at the start of a single text message", mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)

pub |> send(c("other", "this other topic will not be received"), mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)

# specify NULL to subscribe to ALL topics
sub |> subscribe(topic = NULL)
pub |> send(c("newTopic", "this is a new topic"), mode = "raw", echo = FALSE)
sub |> recv("character", keep.raw = FALSE)

sub |> unsubscribe(topic = NULL)
pub |> send(c("newTopic", "this topic will now not be received"), mode = "raw", echo = FALSE)
sub |> recv("character", keep.raw = FALSE)

# however the topics explicitly subscribed to are still received
pub |> send(c("examples will still be received"), mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)

# Subscribed topic can be of any atmoic type, not just character
sub |> subscribe(topic = 1)
pub |> send(c(1, 10, 10, 20), mode = "raw", echo = FALSE)
sub |> recv(mode = "double", keep.raw = FALSE)

close(pub)
close(sub)

# ------------------------------ #
# Demo of surveryor / respondent #
# Scalability Protocol >>        #
# ------------------------------ #
sur <- socket("surveyor", listen = "inproc://nanoservice")
res1 <- socket("respondent", dial = "inproc://nanoservice")
res2 <- socket("respondent", dial = "inproc://nanoservice")

# sur sets a survey timeout, applying to this and subsequent surveys
sur |> survey_time(10000)

# sur sends a message and then requests 2 async receives
sur |> send("service check", echo = FALSE)
aio1 <- sur |> recv_aio()
aio2 <- sur |> recv_aio()

# res1 receives the message and replies using an aio send function
res1 |> recv(keep.raw = FALSE)
res1 |> send_aio("res1")

# res2 receives the message but fails to reply
res2 |> recv(keep.raw = FALSE)

# checking the aio - only the first will have resolved
aio1$data
aio2$data

# after the survey expires, the second resolves into a timeout error
aio2$data

close(sur)
close(res1)
close(res2)

# ------------------------------------ #
# ncurl() minimalist http(s) client >> #
# ------------------------------------ #
ncurl("https://httpbin.org/headers")

# For advanced use, supports additional HTTP methods such as POST or PUT
# ncurl() also supports async
#
res <- ncurl("http://httpbin.org/post", async = TRUE, method = "POST",
             headers = c(`Content-Type` = "application/json", Authorization = "Bearer APIKEY"),
             data = '{"key": "value"}')
res
res$data

# --------------------------------- #
# stream() as a WebSocket client >> #
# --------------------------------- #
# official demo API key used below
s <- stream(dial = "wss://ws.eodhistoricaldata.com/ws/forex?api_token=OeAFFmMliFG5orCUuwAKQ8l4WWFQ67YX",
            textframes = TRUE)
s

s |> recv(keep.raw = FALSE)

s |> send('{"action": "subscribe", "symbols": "EURUSD"}')

s |> recv(keep.raw = FALSE)

s |> recv(keep.raw = FALSE)

s |> recv(keep.raw = FALSE)

s |> recv(keep.raw = FALSE)

s |> recv(keep.raw = FALSE)

close(s)

# -------------------- #
# On to messenger() >> #
# -------------------- #
messenger("abstract://m")

# ------------------------------------------ #
# A taster of mirai <>                       #
# simple and minimalist async execution in R #
# built on NNG / nanonext technology         #
# ------------------------------------------ #
library(mirai)

m <- mirai(x + y + 1, x = 2, y = 3)
m
m$data

m <- mirai(as.matrix(df), df = data.frame(), .timeout = 1000)
call_mirai(m)$data

m <- mirai({
    res <- rnorm(n)
    res / rev(res)
}, n = 5e7)

m$data

m$data

m$data
