from django.db import connection, models
from django.db.models.expressions import RawSQL


class User(models.Model):
    username = models.CharField(max_length=100)
    description = models.TextField(blank=True)


def show_user(username):
    with connection.cursor() as cursor:
        # GOOD -- Using parameters
        cursor.execute("SELECT * FROM users WHERE username = %s", username)
        User.objects.raw("SELECT * FROM users WHERE username = %s", (username,))

        # BAD -- Using string formatting
        cursor.execute("SELECT * FROM users WHERE username = '%s'" % username)

        # BAD -- other ways of executing raw SQL code with string interpolation
        User.objects.annotate(RawSQL("insert into names_file ('name') values ('%s')" % username))
        User.objects.raw("insert into names_file ('name') values ('%s')" % username)
        User.objects.extra("insert into names_file ('name') values ('%s')" % username)

        # BAD (but currently no custom query to find this)
        #
        # It is exposed to SQL injection (https://docs.djangoproject.com/en/2.2/ref/models/querysets/#extra)
        # For example, using name = "; DROP ALL TABLES -- "
        # will result in SQL: SELECT * FROM name WHERE name = ''; DROP ALL TABLES -- ''
        #
        # This shouldn't be very widespread, since using a normal string will result in invalid SQL
        # Using name = "example", will result in SQL: SELECT * FROM name WHERE name = ''example''
        # which in MySQL will give a syntax error
        #
        # When testing this out locally, none of the queries worked against SQLite3, but I could use
        # the SQL injection against MySQL.
        User.objects.raw("SELECT * FROM users WHERE username = '%s'", (username,))


def raw3(arg):
    m = User.objects.filter('foo')
    m = m.filter('bar')
    m.raw("select foo from bar where baz = %s" % arg)


def raw4(arg):
    m = User.objects.filter('foo')
    m.extra("select foo from bar where baz = %s" % arg)


def update_user(key, description1):
    # Neither of these are exposed to sql-injections
    user = User.objects.get(pk=key)
    item.description = description
