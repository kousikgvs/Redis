# This file tells Docker how to build our app's box (image).
# Docker reads it from top to bottom, one step at a time.
# Each step makes a small "layer". Docker remembers old layers,
# so if a step did not change, it skips doing it again. Fast!
# That is why we put steps that almost never change at the top.

# FROM = "start with this ready-made box".
# We start with a box that already has Python 3.12 inside.
# This way we do not have to install Python ourselves.
# "slim" means it is a small box (around 120 MB) with only what we need.
# A small box is faster to download and has fewer parts that can break.
# We do NOT use "alpine" because some Python libraries do not work well on it.
FROM python:3.12-slim

# ENV = "set some settings that stay on inside the box".
# We set two of them together to keep the box a tiny bit smaller.
#
# PYTHONDONTWRITEBYTECODE=1
#   Tells Python: please do not save those extra .pyc cache files.
#   We do not need them in a container, they just make a mess.
#
# PYTHONUNBUFFERED=1
#   Tells Python: print() messages should show up right away.
#   Without this, our messages can get stuck and we see nothing in the logs.
#   That is bad when we are trying to find a bug.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# WORKDIR = "go into this folder, and make it if it is not there".
# From now on, every step works inside /app.
# We pick /app because it is short, easy to remember,
# and it is not mixed up with system folders.
WORKDIR /app

# Now we copy ONLY the file that lists our Python libraries.
# Why only this one file first? Because of Docker's memory (cache).
# If this file did not change, Docker will skip the slow "pip install" step
# next time we build. If we copied everything first, even a tiny code change
# would force pip to install all libraries again. That is slow and wasteful.
COPY requirements.txt .

# RUN = "run this command while building the box".
# Here we ask pip to install all libraries from requirements.txt.
#
# --no-cache-dir tells pip: do not keep the download files after install.
# We will never need them again inside this box, so keeping them
# would just make the box bigger for no reason.
RUN pip install --no-cache-dir -r requirements.txt

# Now copy the rest of our project files into the box.
# The first "." means "everything in the folder on my computer".
# The second "." means "put it into /app inside the box" (our WORKDIR).
# Tip: a .dockerignore file should hide things like venv/ and .git/
# so they do not get copied in (they would make the box big and slow).
COPY . .

# Set the default Redis address. We use settings (env vars) instead of
# writing the address inside our Python code. Why?
# Because the same box should work in different places:
#   1. On your laptop alone        -> you can change it to localhost
#   2. With docker-compose         -> compose changes it to "redis"
#   3. On a real server later      -> the server can give it a real address
# Putting the values here just gives a friendly default that already
# matches our docker-compose setup, so "docker compose up" just works.
ENV REDIS_HOST=redis \
    REDIS_PORT=6379

# CMD = "this is the command to run when the box starts".
# We write it as a list ["python", "code.py"] (called the exec form).
# This is important! With the list form, Python is the main program in
# the box. So when Docker says "please stop", Python hears it and can
# shut down nicely (for example, close the Redis connection).
# If we wrote it as plain text "python code.py", a shell would wrap it,
# and the shell can eat the stop signal. Then Docker waits 10 seconds
# and kills the box hard. We want the nice, clean stop.
CMD ["python", "code.py"]
