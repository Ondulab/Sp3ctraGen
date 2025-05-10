/*
 * Copyright (C) 2025 - present Ondulab
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 */

#include "../include/TaskManager.h"
#include <QDebug>
#include <QtConcurrent/QtConcurrent>

// Initialization of the static instance
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
    // Cancel all running tasks
    cancelAllTasks();
}

QUuid TaskManager::runTask(std::function<void(ProgressCallback)> task, 
                         TaskCallback callback)
{
    // Generate a unique identifier for the task
    QUuid taskId = QUuid::createUuid();
    
    // Create a watcher to track the task
    QFutureWatcher<void>* watcher = new QFutureWatcher<void>(this);
    
    // Create a progress function that emits the appropriate signal
    ProgressCallback progressCallback = [this, taskId](int progress, const QString& message) {
        emit taskProgressUpdated(taskId, progress, message);
    };
    
    // Connect the watcher signals
    connect(watcher, &QFutureWatcher<void>::finished, this, [this, taskId, watcher, callback]() {
        // Call the callback function
        if (callback) {
            callback(true, "Task completed successfully");
        }
        
        // Emit the task completion signal
        emit taskCompleted(taskId, true, "Task completed successfully");
        
        // Cleanup
        m_tasks.remove(taskId);
        watcher->deleteLater();
    });
    
    // Store task information
    TaskInfo taskInfo;
    taskInfo.watcher = watcher;
    taskInfo.callback = callback;
    taskInfo.progressCallback = progressCallback;
    m_tasks[taskId] = taskInfo;
    
    // Start the task
    QFuture<void> future = QtConcurrent::run([task, progressCallback]() {
        try {
            task(progressCallback);
        } catch (const std::exception& e) {
            qWarning() << "Exception in task:" << e.what();
        } catch (...) {
            qWarning() << "Unknown exception in task";
        }
    });
    
    // Associate the watcher with the task
    watcher->setFuture(future);
    
    // Emit the task start signal
    emit taskStarted(taskId);
    
    return taskId;
}

bool TaskManager::cancelTask(const QUuid& taskId)
{
    if (!m_tasks.contains(taskId)) {
        qWarning() << "Attempt to cancel a non-existent task:" << taskId;
        return false;
    }
    
    TaskInfo taskInfo = m_tasks[taskId];
    
    // Cancel the task
    taskInfo.watcher->cancel();
    
    // Call the callback function with a failure status
    if (taskInfo.callback) {
        taskInfo.callback(false, "Task cancelled");
    }
    
    // Emit the cancellation signal
    emit taskCancelled(taskId);
    
    // Cleanup
    m_tasks.remove(taskId);
    taskInfo.watcher->deleteLater();
    
    return true;
}

void TaskManager::cancelAllTasks()
{
    // Copy the identifiers to avoid modification issues during iteration
    QList<QUuid> taskIds = m_tasks.keys();
    
    // Cancel each task
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