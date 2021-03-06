#ifndef FLIELOGIC_H
#define FLIELOGIC_H

#include <QElapsedTimer>
#include <QObject>
#include <QPoint>
#include <QQuickItem>

class FlieLogic : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(int cellId READ cellId NOTIFY cellIdChanged)
    Q_PROPERTY(int speed READ speed NOTIFY pathChanged)
    Q_PROPERTY(int path  READ path  NOTIFY pathChanged)
    Q_PROPERTY(int age   READ age   NOTIFY ageChanged)
    Q_PROPERTY(bool corpse READ corpse NOTIFY corpseChanged)
    Q_PROPERTY(int determination READ determination WRITE setDetermination NOTIFY determinationChanged)
    Q_PROPERTY(int scurryIntvl READ scurryIntvl NOTIFY scurryIntvlChanged)
    Q_PROPERTY(QPointF flieStartPos READ flieStartPos WRITE setFlieStartPos NOTIFY flieStartPosChanged)
    Q_PROPERTY(bool pause READ pause WRITE setPause NOTIFY pauseChanged)
    Q_PROPERTY(int fieldSize  READ fieldSize  WRITE setFieldSize  NOTIFY fieldSizeChanged)
    Q_PROPERTY(QQuickItem* cell     WRITE setCell    NOTIFY cellChanged)
    Q_PROPERTY(QQuickItem* fliePic  WRITE setFliePic NOTIFY fliePicChanged)

public:
    explicit FlieLogic(QQuickItem *parent = nullptr);

    int   scurryIntvl() const;
    int         speed() const;
    int        cellId() const { return m_cellIndex; }
    bool       corpse() const { return m_corpse;}
    int         path () const { return m_path;}
    int determination() const { return m_migratTimerInterval/1000; }
    int           age() const { return (m_liveTimer->elapsed() - m_pausePeriod)/1000;}
    int     fieldSize() const { return m_fieldSize; }
    bool        pause() const { return m_pause;}
    QPointF flieStartPos() const { return m_flieStartPos; }

    void setCell(QQuickItem *obj);
    void setFliePic(QQuickItem *obj);
    void setFieldSize(int size);
    void setFlieStartPos(QPointF val);
    void setDetermination(int val);

public slots:
    void setPause(bool pause);

signals:
    void fieldSizeChanged();
    void fliePicChanged();
    void cellChanged();
    void pauseChanged();

    void flieStartPosChanged();
    void scurryIntvlChanged();
    void determinationChanged();
    void ageChanged();
    void pathChanged();
    void corpseChanged();
    void cellIdChanged();

    void startMigrate(int oldCell, int newCell);
    void isDie(int Cell);

protected:
    virtual void timerEvent(QTimerEvent*);
private:
    void start();
    void stop();
    int  rotateToCenter(const QPointF& flInCellPos);
    void makeMove();
    void setMaxAge();
    void checkAge();

    void startMigration(QQuickItem* item , int newCell ); //переход "Взлет" в диаграмме
    void finishMigration(); //переход   "Посадка"  в диаграмме
    void scurry();          //состояние "Ползание" в диаграмме
    void fly();             //состояние "Полет"  в диаграмме
    void die();             //переход   "Смерть" в диаграмме

private:
    QScopedPointer<QElapsedTimer> m_liveTimer;
    int m_migrationTimerId = 0;
    int m_moveTimerId      = 0;

    bool m_flFly   = false;
    bool m_pause   = true;
    bool m_corpse  = false;
    int  m_maxAge  = 1000; //необходимое время для инициализации свойства в QML

    int    m_rotateSign   = 1;
    double m_rotate       = 0;
    double m_move         = 0;
    double m_path         = 0;
    double m_fieldSize    = 0;
    int    m_pausePeriod  = 0;
    int    m_startPause   = 0;
    QPointF m_flieStartPos   ;

    double m_flieW = 0;
    double m_flieH = 0;
    QQuickItem* m_fliePic  = nullptr;
    QQuickItem* m_cell     = nullptr;
    int  m_cellIndex = -1;

    int  m_migratTimerInterval = 15000;

    static int m_registrateVal;
};

#endif // FLIELOGIC_H
