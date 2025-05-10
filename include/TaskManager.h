/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

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
 * @brief Background task manager
 *
 * This class provides a unified interface for executing tasks
 * in the background and tracking their progress.
 */
class TaskManager : public QObject
{
    Q_OBJECT
    
public:
    /**
     * @brief Callback function type for tasks
     */
    using TaskCallback = std::function<void(bool success, const QString& message)>;
    
    /**
     * @brief Progress function type for tasks
     */
    using ProgressCallback = std::function<void(int progress, const QString& message)>;
    
    /**
     * @brief Gets the unique instance of the task manager (Singleton)
     *
     * @return Task manager instance
     */
    static TaskManager* getInstance();
    
    /**
     * @brief Runs a task in the background
     *
     * @param task Function to execute
     * @param callback Callback function to call when the task is completed
     * @param progressCallback Callback function for progress (optional)
     * @return Unique task identifier
     */
    QUuid runTask(std::function<void(ProgressCallback)> task, 
                 TaskCallback callback);
    
    /**
     * @brief Cancels a running task
     *
     * @param taskId Identifier of the task to cancel
     * @return true if the task was cancelled
     */
    bool cancelTask(const QUuid& taskId);
    
    /**
     * @brief Cancels all running tasks
     */
    void cancelAllTasks();
    
    /**
     * @brief Checks if a task is running
     *
     * @param taskId Task identifier
     * @return true if the task is running
     */
    bool isTaskRunning(const QUuid& taskId) const;
    
    /**
     * @brief Gets the number of running tasks
     *
     * @return Number of running tasks
     */
    int runningTaskCount() const;
    
signals:
    /**
     * @brief Signal emitted when a task is started
     *
     * @param taskId Task identifier
     */
    void taskStarted(const QUuid& taskId);
    
    /**
     * @brief Signal emitted when a task is completed
     *
     * @param taskId Task identifier
     * @param success Task success
     * @param message Result message
     */
    void taskCompleted(const QUuid& taskId, bool success, const QString& message);
    
    /**
     * @brief Signal emitted when a task is cancelled
     *
     * @param taskId Task identifier
     */
    void taskCancelled(const QUuid& taskId);
    
    /**
     * @brief Signal emitted when task progress is updated
     *
     * @param taskId Task identifier
     * @param progress Progress (0-100)
     * @param message Progress message
     */
    void taskProgressUpdated(const QUuid& taskId, int progress, const QString& message);
    
private:
    /**
     * @brief Private constructor (Singleton)
     *
     * @param parent Parent object
     */
    explicit TaskManager(QObject *parent = nullptr);
    
    /**
     * @brief Destructor
     */
    ~TaskManager();
    
    /**
     * @brief Structure to store task information
     */
    struct TaskInfo {
        QFutureWatcher<void>* watcher;
        TaskCallback callback;
        ProgressCallback progressCallback;
    };
    
    static TaskManager* s_instance; // Unique instance (Singleton)
    QMap<QUuid, TaskInfo> m_tasks; // Running tasks
};

#endif // TASKMANAGER_H