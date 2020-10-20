#include "FlieLogic.h"

#include <QTimerEvent>
#include <QRandomGenerator>
#include <QtQml>
#include <QDebug>

#define UNDEAD

static const int    g_rotateRandomMax = 30;
static const int    g_scurryInterval  = 60;
static const double g_rotateStep      = 1;
static const int    g_returnSpeed     = 3;
static const int    g_flySpeed        = 5;
static const int    g_brakingDistance = 70;
static const int    g_landingDistance = 30;

int FlieLogic::m_registrateVal = qmlRegisterType<FlieLogic>("flie.components",1,0,"FlieLogic");

FlieLogic::FlieLogic(QQuickItem *parent):
    QQuickItem(parent),
    m_liveTimer(new QElapsedTimer())
{
    start();
    m_liveTimer->start();
}

int FlieLogic::scurryIntvl() const
{
    return g_scurryInterval;
}
///
/// \brief FlieLogic::speed
/// \return pixel per second
///
int FlieLogic::speed() const
{
    return qRound(m_move/g_scurryInterval * 1000);
}

void FlieLogic::setFieldSize(int size)
{
    if(m_fieldSize == size) return;

    m_fieldSize = size;

    changeMaxAge();

    emit fieldSizeChanged();
}

void FlieLogic::setFlieStartPos(QPointF val)
{
    if(m_flieStartPos == val) return;

    m_flieStartPos = val;
    emit flieStartPosChanged();

    if(!m_fliePic) return;
    stop();
    m_fliePic->setX( m_flieStartPos.rx() - m_fliePic->width() /4);
    m_fliePic->setY( m_flieStartPos.ry() - m_fliePic->height()/4);
    start();
}

void FlieLogic::setDetermination(int val)
{
    if(m_migratTimerInterval/1000 == val) return;

    m_migratTimerInterval = val*1000;

    changeMaxAge();

    emit determinationChanged();
}

void FlieLogic::setFliePic(QQuickItem *obj)
{
    if(m_fliePic == obj) return;

    m_fliePic = obj;
    emit fliePicChanged();

    if(!m_fliePic) return;

    m_fliePic->setParentItem(this);
    m_fliePic->setRotation(QRandomGenerator::global()->bounded(360));

    connect(m_fliePic,&QQuickItem::widthChanged, [this](){ m_flieW = m_fliePic->width()/2. ;});
    connect(m_fliePic,&QQuickItem::heightChanged,[this](){ m_flieH = m_fliePic->height()/2.;});
}

void FlieLogic::setCell(QQuickItem *obj)
{
    if(m_cell == obj) return;

    m_cell = obj;
    emit cellChanged();

    if(m_cell){
        bool ok;
        m_cellIndex = m_cell->property("index").toInt(&ok);
        Q_ASSERT(ok);
    }else
        m_cellIndex = -1;

    emit cellIdChanged();
}

void FlieLogic::setPause(bool pause)
{
    if(m_corpse) return;

    pause ? stop() : start();

    if(pause){
        m_startPause = m_liveTimer->elapsed();
    }else if(m_startPause){
        m_pausePeriod += m_liveTimer->elapsed() - m_startPause;
        m_startPause = 0;
    }
}

void FlieLogic::timerEvent(QTimerEvent *event)
{
    if(!m_pause) emit ageChanged();

    if(!m_fliePic) return; //нет обьекта, нет движения

    if(m_migrationTimerId == event->timerId() && m_cell)
    {

        int newCell = 0;
        do{ newCell = QRandomGenerator::global()->bounded(m_fieldSize);
        }while(newCell == m_cellIndex);

        for(QQuickItem* item : parentItem()->childItems())
            if(item->objectName() == "Cell"+QString::number(newCell)){
                if(item->property("isFull").toBool() == false){
                    startMigration(item, newCell );
                    break;
                }
                else changeMaxAge(m_migratTimerInterval/2);
            }
    }

    if(m_moveTimerId == event->timerId()){
        if(m_flFly) this->fly();
        else        this->scurry();
    }
}

void FlieLogic::start()
{
    m_migrationTimerId = startTimer(m_migratTimerInterval, Qt::CoarseTimer);
    Q_ASSERT(m_migrationTimerId);
    m_moveTimerId    = startTimer(g_scurryInterval, Qt::CoarseTimer);
    Q_ASSERT(m_moveTimerId);
    m_pause = false;
    emit pauseChanged();
}

void FlieLogic::stop()
{
    killTimer(m_migrationTimerId);
    killTimer(m_moveTimerId);
    m_migrationTimerId = 0;
    m_moveTimerId    = 0;
    m_pause = true;
    emit pauseChanged();
}

void FlieLogic::startMigration(QQuickItem* item, int newCell)
{
    killTimer(m_moveTimerId);      m_moveTimerId = 0;
    killTimer(m_migrationTimerId); m_migrationTimerId = 0;

    emit startMigrate(m_cellIndex, newCell);
    this->setCell(item);

    if(m_fliePic) m_fliePic->setVisible(false);
    m_flFly = true;

    m_moveTimerId = startTimer(g_scurryInterval, Qt::CoarseTimer);
    Q_ASSERT(m_moveTimerId);
}

void FlieLogic::finishMigration()
{
    if(m_fliePic) m_fliePic->setVisible(true);
    m_flFly = false;

    m_migrationTimerId = startTimer(m_migratTimerInterval, Qt::CoarseTimer);
    Q_ASSERT(m_migrationTimerId);
}

int FlieLogic::rotateToCenter(const QPointF& flInCellPos)
{
    QPointF vec (m_cell->width()/2 - flInCellPos.x(),
                 - (m_cell->height()/2 - flInCellPos.y()));
    double centrAngle = qRadiansToDegrees(std::atan2(vec.x(),vec.y())) ;
    double flieAngle = m_fliePic->rotation();

    while(centrAngle < 0)   centrAngle += 360;
    while(centrAngle > 360) centrAngle -= 360;
    while(flieAngle  < 0)   flieAngle  += 360;
    while(flieAngle  > 360) flieAngle  -= 360;

    double delta = centrAngle - flieAngle;

    while(delta < 0)   delta += 360;

    if(delta >= 0 && delta < 180 )
        return  g_returnSpeed;
    else
        return -g_returnSpeed;
}

void FlieLogic::scurry()
{
    checkAge();

    m_move = 1 + QRandomGenerator::global()->generateDouble();

    bool isOutBorder = false;
    if(m_cell)
    {
        QPointF flInCellPos = mapToItem(m_cell, QPointF(m_fliePic->x(),m_fliePic->y()));

        if(flInCellPos.x() < 0 || flInCellPos.x() > m_cell->width() - m_fliePic->width() ||
           flInCellPos.y() < 0 || flInCellPos.y() > m_cell->height() - m_fliePic->height())
        {
            isOutBorder  = true;
            m_rotateSign = rotateToCenter(flInCellPos);
        }
    }

    if(!isOutBorder){
        if(m_rotate < g_rotateStep){
            m_rotateSign = QRandomGenerator::global()->generateDouble() > 0.5 ? 1 : -1;
            m_rotate     = QRandomGenerator::global()->bounded(g_rotateRandomMax);
        }
        m_rotate -= g_rotateStep;
    }

    makeMove();
}

void FlieLogic::fly()
{
    Q_ASSERT(m_cell);

    QPointF flInCellPos = mapToItem(m_cell, QPointF(m_fliePic->x(),m_fliePic->y()));
    m_rotateSign = rotateToCenter(flInCellPos);

    QVector2D vec (m_cell->width()/2 - flInCellPos.x(),
                    - (m_cell->height()/2 - flInCellPos.y()));

    m_move = g_flySpeed + QRandomGenerator::global()->generateDouble();
    if(vec.length() < g_brakingDistance) m_move /= 2; //эмитация ПИД регуляции, что бы не пролететь мимо

    if(vec.length() < g_landingDistance){
        finishMigration();
        return;
    }

    makeMove();
}

void FlieLogic::makeMove()
{
    m_path += m_move;
    emit pathChanged();

    QPointF mapPos = parentItem()->mapFromItem(m_fliePic,
                                               QPointF(m_flieW, m_flieH - m_move));

    m_fliePic->setX(mapPos.x()-m_flieW);
    m_fliePic->setY(mapPos.y()-m_flieH);
    m_fliePic->setRotation(m_fliePic->rotation() + m_rotateSign*g_rotateStep);
}

void FlieLogic::changeMaxAge(int decrease)
{
    if(m_fieldSize)
        m_maxAge = m_migratTimerInterval * m_fieldSize;
    else
        m_maxAge = m_migratTimerInterval;

#ifdef UNDEAD
    m_maxAge -= decrease*2;
#else
    m_maxAge -= decrease;
#endif

    checkAge();
}

void FlieLogic::checkAge()
{
#ifdef UNDEAD
    if(m_maxAge <= 0) // возраст не ограничен. насекомое живет пока может перемещаться по полям в поисках пищи
#else
    if((m_liveTimer->elapsed() - m_pausePeriod) > m_maxAge) // возраст ограничен
#endif
        this->die();
}

void FlieLogic::die()
{
    stop();
    m_fliePic->setOpacity(0.3);
    m_corpse = true;

    emit isDie(m_cellIndex);
    emit corpseChanged();
}
