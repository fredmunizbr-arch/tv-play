#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QCoreApplication::setApplicationName("TV PLAYOUT");
    QCoreApplication::setOrganizationName("TV PLAYOUT");

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/qt/qml/TVPlayout/src/Main.qml"_qs);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);
    return app.exec();
}
