import mariadb


def initDb(db: mariadb.connection.Connection):
    db.create_all()
    db.session.commit()
