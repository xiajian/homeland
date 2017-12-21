# -*- encoding : utf-8 -*-
require 'redis-namespace'

$redis = Redis::Namespace.new('homeland', redis: Redis.new(password: 'Fy958e5mmyb7Ta4H', db: 0))
