#ifndef TASKMANAGER_H
#define TASKMANAGER_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QUuid>
#include <QFuture>
#include <QFutureWatcher>
#include <functional>

/**
 * @brief Gestionnaire de tâches en arrière-plan
 * 
 * Cette classe fournit une interface unifiée pour exécuter des tâches
 * en arrière-plan et suivre leur progression.
 */
class TaskManager : public QObject
{
    Q_OBJECT
    
public:
    /**
     * @brief Type de fonction de rappel pour les tâches
     */
    using TaskCallback = std::function<void(bool success, const QString& message)>;
    
    /**
     * @brief Type de fonction de progression pour les tâches
     */
    using ProgressCallback = std::function<void(int progress, const QString& message)>;
    
    /**
     * @brief Obtient l'instance unique du gestionnaire de tâches (Singleton)
     * 
     * @return Instance du gestionnaire de tâches
     */
    static TaskManager* getInstance();
    
    /**
     * @brief Exécute une tâche en arrière-plan
     * 
     * @param task Fonction à exécuter
     * @param callback Fonction de rappel à appeler lorsque la tâche est terminée
     * @param progressCallback Fonction de rappel pour la progression (optionnelle)
     * @return Identifiant unique de la tâche
     */
    QUuid runTask(std::function<void(ProgressCallback)> task, 
                 TaskCallback callback);
    
    /**
     * @brief Annule une tâche en cours
     * 
     * @param taskId Identifiant de la tâche à annuler
     * @return true si la tâche a été annulée
     */
    bool cancelTask(const QUuid& taskId);
    
    /**
     * @brief Annule toutes les tâches en cours
     */
    void cancelAllTasks();
    
    /**
     * @brief Vérifie si une tâche est en cours
     * 
     * @param taskId Identifiant de la tâche
     * @return true si la tâche est en cours
     */
    bool isTaskRunning(const QUuid& taskId) const;
    
    /**
     * @brief Obtient le nombre de tâches en cours
     * 
     * @return Nombre de tâches en cours
     */
    int runningTaskCount() const;
    
signals:
    /**
     * @brief Signal émis lorsqu'une tâche est démarrée
     * 
     * @param taskId Identifiant de la tâche
     */
    void taskStarted(const QUuid& taskId);
    
    /**
     * @brief Signal émis lorsqu'une tâche est terminée
     * 
     * @param taskId Identifiant de la tâche
     * @param success Succès de la tâche
     * @param message Message de résultat
     */
    void taskCompleted(const QUuid& taskId, bool success, const QString& message);
    
    /**
     * @brief Signal émis lorsqu'une tâche est annulée
     * 
     * @param taskId Identifiant de la tâche
     */
    void taskCancelled(const QUuid& taskId);
    
    /**
     * @brief Signal émis lorsque la progression d'une tâche est mise à jour
     * 
     * @param taskId Identifiant de la tâche
     * @param progress Progression (0-100)
     * @param message Message de progression
     */
    void taskProgressUpdated(const QUuid& taskId, int progress, const QString& message);
    
private:
    /**
     * @brief Constructeur privé (Singleton)
     * 
     * @param parent Objet parent
     */
    explicit TaskManager(QObject *parent = nullptr);
    
    /**
     * @brief Destructeur
     */
    ~TaskManager();
    
    /**
     * @brief Structure pour stocker les informations d'une tâche
     */
    struct TaskInfo {
        QFutureWatcher<void>* watcher;
        TaskCallback callback;
        ProgressCallback progressCallback;
    };
    
    static TaskManager* s_instance; // Instance unique (Singleton)
    QMap<QUuid, TaskInfo> m_tasks; // Tâches en cours
};

#endif // TASKMANAGER_H