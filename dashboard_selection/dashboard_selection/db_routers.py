
class MysqlRouter(object):
    def db_for_read(self, model, **hints):
        return 'data'
