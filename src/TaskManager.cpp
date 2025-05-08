#include "../include/TaskManager.h"
#include <QDebug>
#include <QtConcurrent/QtConcurrent>

// Initialisation de l'instance statique
TaskManager* TaskManager::s_instance = nullptr;

TaskManager* TaskManager::getInstance()
{
    if (!s_instance) {
        s_instance = new TaskManager();
    }
    return s_instance;
}

TaskManager::TaskManager(QObject *parent)
    : QObject(parent)
{
}

TaskManager::~TaskManager()
{
    // Annuler toutes les tâches en cours
    cancelAllTasks();
}

QUuid TaskManager::runTask(std::function<void(ProgressCallback)> task, 
                         TaskCallback callback)
{
    // Générer un identifiant unique pour la tâche
    QUuid taskId = QUuid::createUuid();
    
    // Créer un watcher pour suivre la tâche
    QFutureWatcher<void>* watcher = new QFutureWatcher<void>(this);
    
    // Créer une fonction de progression qui émet le signal approprié
    ProgressCallback progressCallback = [this, taskId](int progress, const QString& message) {
        emit taskProgressUpdated(taskId, progress, message);
    };
    
    // Connecter les signaux du watcher
    connect(watcher, &QFutureWatcher<void>::finished, this, [this, taskId, watcher, callback]() {
        // Appeler la fonction de rappel
        if (callback) {
            callback(true, "Tâche terminée avec succès");
        }
        
        // Émettre le signal de fin de tâche
        emit taskCompleted(taskId, true, "Tâche terminée avec succès");
        
        // Nettoyer
        m_tasks.remove(taskId);
        watcher->deleteLater();
    });
    
    // Stocker les informations de la tâche
    TaskInfo taskInfo;
    taskInfo.watcher = watcher;
    taskInfo.callback = callback;
    taskInfo.progressCallback = progressCallback;
    m_tasks[taskId] = taskInfo;
    
    // Démarrer la tâche
    QFuture<void> future = QtConcurrent::run([task, progressCallback]() {
        try {
            task(progressCallback);
        } catch (const std::exception& e) {
            qWarning() << "Exception dans la tâche:" << e.what();
        } catch (...) {
            qWarning() << "Exception inconnue dans la tâche";
        }
    });
    
    // Associer le watcher à la tâche
    watcher->setFuture(future);
    
    // Émettre le signal de démarrage de tâche
    emit taskStarted(taskId);
    
    return taskId;
}

bool TaskManager::cancelTask(const QUuid& taskId)
{
    if (!m_tasks.contains(taskId)) {
        qWarning() << "Tentative d'annulation d'une tâche inexistante:" << taskId;
        return false;
    }
    
    TaskInfo taskInfo = m_tasks[taskId];
    
    // Annuler la tâche
    taskInfo.watcher->cancel();
    
    // Appeler la fonction de rappel avec un statut d'échec
    if (taskInfo.callback) {
        taskInfo.callback(false, "Tâche annulée");
    }
    
    // Émettre le signal d'annulation
    emit taskCancelled(taskId);
    
    // Nettoyer
    m_tasks.remove(taskId);
    taskInfo.watcher->deleteLater();
    
    return true;
}

void TaskManager::cancelAllTasks()
{
    // Copier les identifiants pour éviter les problèmes de modification pendant l'itération
    QList<QUuid> taskIds = m_tasks.keys();
    
    // Annuler chaque tâche
    for (const QUuid& taskId : taskIds) {
        cancelTask(taskId);
    }
}

bool TaskManager::isTaskRunning(const QUuid& taskId) const
{
    return m_tasks.contains(taskId);
}

int TaskManager::runningTaskCount() const
{
    return m_tasks.size();
}