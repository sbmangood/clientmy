#include "bgimg.h"
#include <QVBoxLayout>
#include <QDebug>
#include <QPainter>
#include <QtNetwork>

BGImg::BGImg(QString lessonId, QString date, QString path, QString trail, QSize size, QQuickPaintedItem *parent) :
    QQuickPaintedItem(parent)
    , boardSize(size)
    , lessonId(lessonId)
    , date(date)
    , currentWidth(1.0)
    , currentHeight(1.0)
{
    QPixmap pixmap(100, 100);
    pixmap.fill(Qt::white);
    currentPixmap = pixmap;
    changeBgimg(pixmap, 1.0, 1.0);

    board = new PainterBoard(parent);//lessonId,path,trail,boardSize,this);
    connect(board, &PainterBoard::changeBgimg, this, &BGImg::loadNetImg);

    docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QDir dir;

    if (!dir.exists(docPath + "/YiMi/" + date + "/" + lessonId))
    {
        dir.mkpath(docPath + "/YiMi/" + date + "/" + lessonId);
    }
    soucePath = docPath + "/YiMi/" + date + "/" + lessonId + "/";
    docPath = soucePath;
    manager = new QNetworkAccessManager(this);
    //qDebug()<< "BGImg::BGImg" << size << lessonId << date << path << trail;
}

BGImg::~BGImg()
{
}

void BGImg::changeBgimg(QPixmap pixmap, double width, double height)
{
    currentWidth = width;
    currentHeight = height;
    currentPixmap = pixmap;
    emit imageChanged(currentPixmap);
    emit update(docPath);
    //qDebug()<< "BGImg::changeBgimg" << docPath;
}

void BGImg::resizeUI(QSize size)
{
    boardSize = size;
    emit update(docPath);
    emit imageChanged(currentPixmap);
    //board->resizeUI(size);
}

void BGImg::loadNetImg(QString url, double width, double height)
{
    //qDebug() << "BGImg::loadNetImg"<< url;
    if (url == "")
    {
        changeBgimg(QPixmap(1, 1), 0, 0);
        return ;
    }
    QString fileName = QCryptographicHash::hash(url.toLatin1(), QCryptographicHash::Md5).toHex().toLower();
    docPath = soucePath + fileName + ".png";
    QFile file(docPath);
    if (!file.exists())
    {
        QNetworkReply *reply = manager->get(QNetworkRequest(QUrl(url)));
        QEventLoop loop;
        QObject::connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
        loop.exec();
        if (reply->error() == QNetworkReply::NoError)
        {
            QByteArray bytes = reply->readAll();
            QPixmap pixmap;
            pixmap.loadFromData(bytes);
            pixmap.save(docPath, "PNG");
            changeBgimg(pixmap, width, height);
            emit displayerBackImage(docPath);
        }
        else
        {
            qDebug() << QStringLiteral("下载图片出错");
        }
        reply->deleteLater();
    }
    else
    {

        QPixmap pixmap(docPath);
        qDebug() << "exists::" << docPath;
        emit displayerBackImage(docPath);
        changeBgimg(pixmap, width, height);
    }
}

void BGImg::paintEvent(QPaintEvent *event)
{
    QPainter painter;
    QPixmap targetPixmap(boardSize);
    targetPixmap.fill(Qt::white);
    painter.begin(&targetPixmap);
    painter.drawPixmap(0, 0, boardSize.width()*currentWidth, boardSize.height()*currentHeight
                       , currentPixmap.scaled(boardSize.width()*currentWidth, boardSize.height()*currentHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation));
    painter.end();
    //painter.begin();
    painter.drawPixmap(0, 0, boardSize.width(), boardSize.height(), targetPixmap);
    painter.end();
}
