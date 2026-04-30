"""Redis sample code - basic operations using redis-py.

Prerequisites:
    pip install redis
    Redis server running on localhost:6379 (e.g., `docker run -p 6379:6379 redis`)
"""

import redis


def main() -> None:
    # Connect to Redis (decode_responses=True returns str instead of bytes)
    r = redis.Redis(host="localhost", port=6379, db=0, decode_responses=True)

    # --- Strings ---
    r.set("name", "Alice")
    r.set("visits", 0)
    r.incr("visits")
    r.incr("visits")
    print("name   :", r.get("name"))
    print("visits :", r.get("visits"))

    # Expiration (TTL in seconds)
    r.set("session:abc", "token-xyz", ex=60)
    print("ttl    :", r.ttl("session:abc"), "sec")

    # --- Hashes (objects) ---
    r.hset("user:1", mapping={"name": "Alice", "age": 30, "city": "Seattle"})
    print("user:1 :", r.hgetall("user:1"))

    # --- Lists (queue) ---
    r.delete("tasks")
    r.rpush("tasks", "task-1", "task-2", "task-3")
    print("tasks  :", r.lrange("tasks", 0, -1))
    print("pop    :", r.lpop("tasks"))

    # --- Sets ---
    r.delete("tags")
    r.sadd("tags", "redis", "cache", "db")
    print("tags   :", r.smembers("tags"))

    # --- Sorted sets (leaderboard) ---
    r.delete("scores")
    r.zadd("scores", {"alice": 100, "bob": 200, "carol": 150})
    print("top 3  :", r.zrevrange("scores", 0, 2, withscores=True))

    # --- Cleanup demo keys ---
    r.delete("name", "visits", "session:abc", "user:1", "tasks", "tags", "scores")


if __name__ == "__main__":
    main()
